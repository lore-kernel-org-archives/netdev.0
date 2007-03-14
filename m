From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2 2.6.20-070313
Date: Wed, 14 Mar 2007 13:32:28 +0100
Message-ID: <45F7EB5C.5010901@trash.net>
References: <20070313151549.332004c9@freekitty> <200703141223.48927.arekm@maven.pl> <45F7E527.6030307@trash.net> <200703141316.05509.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37620 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161221AbXCNMcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 08:32:50 -0400
In-Reply-To: <200703141316.05509.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arkadiusz Miskiewicz wrote:
> Hm, why no RTA_FWMASK in HEAD rtnetlink.h
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=include/linux/rtnetlink.h;h=4a629ea70cc4ca60a6f486f8653974af68dbe8cd;hb=HEAD
> 
> and 2.6.19
> 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=include/linux/rtnetlink.h;h=3a18addaed4ccb7436bffc9cf5fd0666f145d35c;hb=0215ffb08ce99e2bb59eca114a99499a4d06e704
> 
> ?

Its in include/linux/fib_rules.h:

enum
{
...
        FRA_FWMASK,     /* mask for netfilter mark */

        __FRA_MAX
};

RTA_* attributes aren't used for routing rules anymore inside
the kernel.
