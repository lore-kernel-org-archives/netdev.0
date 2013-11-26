From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 Wake on Lan
Date: Wed, 27 Nov 2013 00:21:01 +0100
Message-ID: <20131126232101.GA7508@electric-eye.fr.zoreil.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pablo Cholaky <mrwaltercool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33104 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758490Ab3KZXVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 18:21:05 -0500
Content-Disposition: inline
In-Reply-To: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Cholaky <mrwaltercool@gmail.com> :
[...]
> I have a HP ENVY laptop with this RealTek, and my laptop don't have a
> BIOS option to disable WOL. I'm currently using a script on start and
> shutdown to disable WOL, but could you guys make a module param to
> enable/disable WOL?

The kernel has to offer a standardized API. Module params are terrible
in this regard. Please forget it.

> This freaking WOL eats a lot of battery on my laptop and my scripts
> don't work when I'm using a hibernation or booting a Linux ISO per
> example.

(if a kernel change can propagate to your ISO, so can your wol
disabling scripts)

There may be something wrong wrt hibernation (real hibernation, not
runtime suspend, right ?) but I do not see how the current code could
change the WoL settings at suspend time for a downed interface.
Care to provide a short description for your hibernation use ?

The XID line included in dmesg output or plain dmesg itself will be
welcome to identify the r8169 chipset. It can make some difference in
the suspend / resume paths.

-- 
Ueimor
