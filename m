From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2 2.6.20-070313
Date: Wed, 14 Mar 2007 13:05:59 +0100
Message-ID: <45F7E527.6030307@trash.net>
References: <20070313151549.332004c9@freekitty> <200703141223.48927.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161179AbXCNMGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 08:06:20 -0400
In-Reply-To: <200703141223.48927.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arkadiusz Miskiewicz wrote:
> This patch
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg27506.html
> 
> didn't make into upstream linux kernel it seems.

As mentioned in the changelog, its in 2.6.19.

> The question is - are patches adding some functionality that's not in upstream 
> kernel accepted?
> 
> There is one wrr patch for iproute floating around that I'm thinking about.

Last time I looked at the WRR patch it was a huge mess and
used architecture dependant types in the netlink messages.
Unless someone fixed this, adding support to iproute is a
bad idea since in case it would get merged compatibility
would break.

