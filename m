From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Is 802.3ad mode in bonding useful ?
Date: Thu, 28 Apr 2011 08:21:02 -0400
Message-ID: <20110428122102.GB4165@hmsreliant.think-freely.org>
References: <4DB9185E.4050103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: WeipingPan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51813 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113Ab1D1MVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 08:21:14 -0400
Content-Disposition: inline
In-Reply-To: <4DB9185E.4050103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2011 at 03:33:50PM +0800, WeipingPan wrote:
> Hi, all,
> 
> 802.3ad mode in bonding implements 802.3ad standard.
> 
> I am just wondering  802.3ad mode is useful,
> since  bonding has many modes like balance-rr, active-backup, etc.
> 
Yes, of course its usefull.  For switches which support 802.3ad, this mode
allows for both peers to understand that the links in the bond are acting as an
aggregate, which makes it easier to prevent things like inadvertently looped
back frames, for which the other modes have to have all sorts of hacks to
prevent.
Neil

> thanks
> Weiping Pan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
