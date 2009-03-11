From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 10:09:38 +0100
Message-ID: <20090311090938.E7BF7832E8B8@gemini.denx.de>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <20090311084430.GU425@pengutronix.de> <20090311.014957.117115597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52465 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbZCKJJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 05:09:44 -0400
In-reply-to: <20090311085721.GV425@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

on Wed, Mar 11, 2009 at 01:49:57AM -0700, David Miller wrote:
> From: Sascha Hauer <s.hauer@pengutronix.de>
> Date: Wed, 11 Mar 2009 09:44:30 +0100
> 
> > On Tue, Mar 10, 2009 at 09:18:41PM -0700, Stephen Hemminger wrote:
> > > Do you still need this? Only works with one board, configuration via
> > > module parameters is discouraged.  Same effect can be done by setting
> > > mac address with regular tools.
> > 
> > Except for root over nfs. Ok, the answer to this is usually 'use
> > initrd', but this is still a pita on embedded systems.
> 
> Please remove this code.  If we let you do it, we have to let everyone
> else do it too, and that's something we don't want to do.
> 
> There are other ways you can handle this, for example have your board
> firmware properly program the MAC address into the card at power-on,
> and then have the driver here look in the MAC address registers to see
> if a valid ethernet address has been left there.

How do you then handle situations where this is impossible? Say, when
the firmware cannot write to those registers for example because  the
ethernet  controller is not even powered on (to reduce power consump-
tion), but will get powered on only in Linux  when  the  driver  gets
loaded (i. e. on demand only, not always)?

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
"If God had wanted us to use the metric system, Jesus would have  had
10 apostles."
