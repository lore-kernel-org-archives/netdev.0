From: Ethan Tuttle <ethan@ethantuttle.com>
Subject: [BUG] mvneta: mirabox ethernet only works if initialized by uboot
Date: Thu, 8 Aug 2013 22:31:37 -0700
Message-ID: <CACzLR4vv4kNVVkFx46jwcmB=hk_aT_XRrvU-Mpc0ZKdEQ-c_Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:45815 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933169Ab3HIFbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 01:31:38 -0400
Received: by mail-oa0-f43.google.com with SMTP id i10so6479643oag.16
        for <netdev@vger.kernel.org>; Thu, 08 Aug 2013 22:31:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I ran into this issue after upgrading my mirabox from the old marvell
kernel to 3.11-rc4.  Although ethernet interfaces are present, and
'link up' is reported, it isn't possible to send or receive packets.
I'm using a vanilla kernel with .config from ArchLinuxARM[1].

Jochen De Smet posted a more detailed report[2] and a work-around on
the Fedora ARM list: if an interface is started using the dhcp command
in uboot, ethernet works in linux.

I reproduced the issue on -rc3 and -rc1 as well, so it isn't a recent
regression.

It should be easy to reproduce on a mirabox, even when tftping a
kernel: just try to use the other interface :).

Reporting here because I don't see any other reports to the
maintainers.  I'm happy to provide more debug output or test patches
if it will help.

Thanks,
Ethan

[1] https://github.com/archlinuxarm/PKGBUILDs/blob/master/core/linux-mvebu/config
[2] http://www.mail-archive.com/arm@lists.fedoraproject.org/msg05244.html
