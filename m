From: "Stefan Lippers-Hollmann" <s.L-H@gmx.de>
Subject: Re: 3.4.x regression: rtl8169: frequent resets
Date: Mon, 2 Jul 2012 02:43:24 +0200
Message-ID: <201207020243.34213.s.L-H@gmx.de>
References: <87y5n7qup0.fsf@spindle.srvr.nix> <20120628193026.GA31627@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:10428 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab2GBAno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 20:43:44 -0400
In-Reply-To: <20120628193026.GA31627@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Thursday 28 June 2012, Francois Romieu wrote:
> Nix <nix@esperi.org.uk> :
> > I recently upgraded from 3.3.x to 3.4.4, and am now experiencing
> > networking problems with my desktop box's r8169 card. The symptoms are
> > that all traffic ceases for five to ten seconds, then the card appears
> > to reset and everything is back to normal -- until it happens again. It
> > can happen quite a lot:
> 
> Can you try and revert 036dafa28da1e2565a8529de2ae663c37b7a0060 ?
> 
> I would welcome a complete dmesg including the XID line from the
> r8169 driver.

r8169 0000:04:00.0: eth0: RTL8168d/8111d at 0xffffc90000c72000, 00:24:1d:72:7c:75, XID 081000c0 IRQ 44
r8169 0000:05:00.0: eth1: RTL8168d/8111d at 0xffffc90000c70000, 00:24:1d:72:7c:77, XID 081000c0 IRQ 45

Kernel 3.4.4 with 036dafa28da1e2565a8529de2ae663c37b7a0060 (r8169: add 
byte queue limit support) reverted is now running just about 60 hours 
on the afformentioned hardware. No traces of "NETDEV WATCHDOG: eth0 
(r8169): transmit queue 0 timed out" so far, while it usually triggers 
within an hour (5 hours at most) with plain 3.4.4 on that system.

Regards
	Stefan Lippers-Hollmann
