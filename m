From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Fwd: Davicom DM9162 PHY supported in the kernel?
Date: Wed, 20 Apr 2016 16:25:13 +0100
Message-ID: <CAOLz05rXhGJ9R_NM=bhhPC8M5=qU=3WomU=3z+8VRgNtUJXL7Q@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35406 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409AbcDTPZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 11:25:34 -0400
Received: by mail-wm0-f48.google.com with SMTP id e201so54942244wme.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 08:25:33 -0700 (PDT)
In-Reply-To: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry, repeat message due to the previous one being HTML)

Hello,

I'm using an embedded Linux board based on an AT91SAM9X25 that uses
the Davicom DM9162IEP PHY chip. I'm struggling to get packets out on
the wire and I'm suspecting that I might have an issue between the
AT91 MAC and the PHY chip. I've looked through the kernel config
options and the kernel already has compiled-in support for the Davicom
PHYs, however I noticed that according to the help text, only the
dm9161e and dm9131 chips are supported, which may indicate why my
ethernet isn't working. I was wondering whether the DM9162 is
backwards compatible with the existing driver? I'm currently using the
mainline kernel 4.3. (p.s. I know the hardware works fine since I have
no problem transferring files using tftp via u-boot).

Thanks,

Amr Bekhit
