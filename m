From: Vincent Pelletier <plr.vincent@gmail.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Fri, 1 Jun 2012 21:20:42 +0200
Message-ID: <201206012120.43235.plr.vincent@gmail.com>
References: <201205312331.06623.plr.vincent@gmail.com> <20120601125949.GA11973@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47200 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699Ab2FATUw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 15:20:52 -0400
Received: by wgbdr13 with SMTP id dr13so2223042wgb.1
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 12:20:51 -0700 (PDT)
In-Reply-To: <20120601125949.GA11973@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the quick reply.

Le vendredi 01 juin 2012 14:59:49, vous avez =E9crit :
> Same thing if you reset and remove the pci device through sysfs then =
ask
> the PCI bridge to scan it again ?

I didn't try it before - but I should have, I know this.
rmmod; reset; modprobe -> doesn't work
rmmod; reset; remove; rescan -> doesn't work either (?!)

> https://bugzilla.kernel.org/show_bug.cgi?id=3D42899 contains similar =
if not
> identical IOMMU messages (this #bz is messy but it may be of interese=
t to
> add yourself to the Cc: list btw).

I found it a bit after my post (while watching the archives, in case so=
meone=20
replied without CC :) ). I posted on that bug as I couldn't find a way =
to just=20
add me to bug CC.

> The r8169 bug is real but the IOMMU message seems rather useless if n=
ot
> bogus.

Just being curious, feel free to skip over my questions:
If it's bogus, could it be a mis-interpretation of its state when the e=
rror=20
occurs (I don't know how CPU knows a fault happened, I guess some IRQ +=
 some=20
register contain error status, address of error, some process/context=20
identifier) ? Or hardware bug ? Or MMU misconfiguration for some reason=
 ?
If it's not bogus, would it be the sign of firmware bug (accessing some=
=20
unpredictable memory upon certain conditions) ?

> You can apply the attached patch but it may not do much for your prob=
lem.
> The patch below could make a difference though. Does it ?

I'll try either and both. Given the poor result I got from=20
reset/remove/rescan, I guess I should reboot between attempts, right ?
Should I prevent original module auto-loading at boot ? Maybe more than=
 just=20
r8169 ?

Regards,
--=20
Vincent Pelletier
