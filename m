From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 10:00:16 -0400
Message-ID: <1236780016.10989.9.camel@localhost.localdomain>
References: <20090311.014957.117115597.davem@davemloft.net>
	 <20090311085721.GV425@pengutronix.de>
	 <20090311090938.E7BF7832E8B8@gemini.denx.de>
	 <20090311.062336.238430706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: wd@denx.de, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40700 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756153AbZCKOCn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 10:02:43 -0400
In-Reply-To: <20090311.062336.238430706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-11 at 06:23 -0700, David Miller wrote:
> From: Wolfgang Denk <wd@denx.de>
> Date: Wed, 11 Mar 2009 10:09:38 +0100
> 
> > How do you then handle situations where this is impossible? Say, when
> > the firmware cannot write to those registers for example because  the
> > ethernet  controller is not even powered on (to reduce power consump-
> > tion), but will get powered on only in Linux  when  the  driver  gets
> > loaded (i. e. on demand only, not always)?
> 
> That's what NVRAM, CMOS, EEPROM's and other writable long-term
> storage areas are for.
> 
> To be quite honest with you, any ethernet device that doesn't
> have an EEPROM where the chip instance's ethernet address is
> stored is completely broken.

Not having persistent MAC storage makes it quite hard from userspace to
tie specific network configuration to a specific device, because
(rightly so) kernel network interface names are *not* stable.  And since
most manufacturers don't bother to put serial numbers into things like
the USB descriptors, there is now way to uniquely identify if you plug
two in.  LOSE.

Save a kitten.  Add an EEPROM.

Dan


