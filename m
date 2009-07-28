From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: fix logic of reverse path filter sysctl
Date: Mon, 27 Jul 2009 18:40:06 -0700 (PDT)
Message-ID: <20090727.184006.260624139.davem@davemloft.net>
References: <20090724123005.35450325@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751597AbZG1Bj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 21:39:59 -0400
In-Reply-To: <20090724123005.35450325@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 24 Jul 2009 12:30:05 -0700

> Even though reverse path filter was changed from simple boolean to trinary control,
> the loose mode only works if both all and device are configured because of
> this logic error.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Good catch, applied, thanks Stephen!
