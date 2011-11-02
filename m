From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: on bnx2x firmware...
Date: Tue, 1 Nov 2011 18:01:19 -0700
Message-ID: <CAHo-OowF1LNmL0P_Rt=oKmhZMt=CVaVsAYkh_XqVJEOzBPXV7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:42634 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab1KBBBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 21:01:20 -0400
Received: by qyk27 with SMTP id 27so7900492qyk.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 18:01:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

((v3.1))$ cat drivers/net/bnx2x/bnx2x_hsi.h | egrep BCM_5710_FW_

#define BCM_5710_FW_MAJOR_VERSION                       7
#define BCM_5710_FW_MINOR_VERSION                       0
#define BCM_5710_FW_REVISION_VERSION            23
#define BCM_5710_FW_ENGINEERING_VERSION         0

So the desired firmware is version 7.0.23.0

((v3.1))$ find | egrep bnx2x | egrep fw
./firmware/bnx2x/bnx2x-e1-6.2.9.0.fw.ihex
./firmware/bnx2x/bnx2x-e2-6.2.9.0.fw.ihex
./firmware/bnx2x/bnx2x-e1h-6.2.9.0.fw.ihex
./drivers/net/bnx2x/bnx2x_fw_defs.h
./drivers/net/bnx2x/bnx2x_fw_file_hdr.h

So it doesn't look like the in-tree fw matches the bnx2x driver in
released v3.1.
I can find this firmware in the firmware repository.

My questions are:
 - is this a bug (and the firmware repo will be merged into a stable
3.1 update),
 - is this a feature, and the 6.2.9.0 firmwares will be removed from the tree?

I guess I'm just not clear on what the current firmware policy is, we
seem to be in some weird half-state.

Thanks,
Maciej.
