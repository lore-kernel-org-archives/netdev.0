From: prashantkumar dhotre <prashantkumardhotre@gmail.com>
Subject: Why max netlink msg size is limited to 16k
Date: Sat, 22 Apr 2017 19:43:20 +0530
Message-ID: <CA+VDgmNYc=djp6ab=n49CTpyvof8CPgHvXRst5Vnm706e-nRvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36849 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424012AbdDVONW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 10:13:22 -0400
Received: by mail-qk0-f178.google.com with SMTP id d80so25734820qke.3
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 07:13:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am observing that max netlink msg that my kernel module can send to
user app is close to 16K.

For larger sizes, genlmsg_unicast() succeeds but my app does not receive data.

I have tried increasing RECV buffer size in my user app but that does not help.

Regards
