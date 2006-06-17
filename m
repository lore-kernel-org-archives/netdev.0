From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 18:27:32 -0700
Message-ID: <1150507652.26368.46.camel@rh4>
References: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
 <87k67glrvl.fsf@blackdown.de> <1150494161.26368.39.camel@rh4>
 <87bqsslk9e.fsf@blackdown.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:49170 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751251AbWFQB0l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 21:26:41 -0400
To: "Juergen Kreileder" <jk@blackdown.de>
In-Reply-To: <87bqsslk9e.fsf@blackdown.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-06-17 at 02:05 +0200, Juergen Kreileder wrote:
> Michael Chan <mchan@broadcom.com> writes:
> > Please try turning TSO off to see if it makes a difference:
> >
> > ethtool -K eth0 tso off
> 
> Seems to work fine with TSO disabled.
> 
Thanks for the information. We'll look into it. If possible, please send
me (using private email) an ethereal trace of a sample of the packets
sent by the tg3 chip right before the NETDEV_WATCHDOG timeout.

In the meantime, I wonder if we should disable TSO by default on the
5780 chip for 2.6.17.

