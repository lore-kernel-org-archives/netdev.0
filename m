From: "Sergey K." <simkergey@gmail.com>
Subject: tc-ipt v0.2: Extension does not know id 1504083504
Date: Sat, 30 Sep 2017 12:34:39 +0600
Message-ID: <CAGv8E+wkpsZL8SMzx+oXei6245RU+SacrBcUN7p2RtXcaBCafw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:52923 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750724AbdI3Gek (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 02:34:40 -0400
Received: by mail-it0-f51.google.com with SMTP id c195so2143152itb.1
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 23:34:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I have to apply this patch

https://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git/commit/?h=v4.10.0&id=97a02cabefb2e2dcfe27f89943709afa84be5525

to my version of iproute2.
But now I have a new information message, when I'm using construction like this:

tc filter add dev eth0 parent ffff: u32 match u32 0 0 action xt -j
MARK --set-mark 0

message text:
tc-ipt v0.2: Extension does not know id 1504083504


I'm using Debian Stretch, kernel 4.9.0-3-amd64, iptables 1.6.0 and
patched iproute 4.9.0

How to solve?
