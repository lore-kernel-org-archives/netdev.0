From: Billy Shuman <wshuman3@gmail.com>
Subject: 4.9.0-rc8: tg3 dead after resume
Date: Wed, 7 Dec 2016 10:20:05 -0500
Message-ID: <CAHQNsodiku6Ln3y-=GzmmNLM0Emc2rEheFmc80OCuN91roojqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:35019 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbcLGPUL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:20:11 -0500
Received: by mail-io0-f174.google.com with SMTP id a124so716515908ioe.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 07:20:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resume on 4.9.0-rc8 tg3 is dead.

In logs I see:
kernel: tg3 0000:44:00.0: phy probe failed, err -19
kernel: tg3 0000:44:00.0: Problem fetching invariants of chip, aborting

rmmod and modprobe does not fix the problem only a reboot resolves the issue.

Billy
