From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: nflog performance ...
Date: Tue, 29 Aug 2017 16:11:52 +0530
Message-ID: <CAA5aLPj=znm_RDVgPGzZj6VixPdWVMCEVco7yxoa4gL0On+pyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35399 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdH2Klx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 06:41:53 -0400
Received: by mail-pf0-f182.google.com with SMTP id g13so9227833pfm.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 03:41:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using ulogd2 to log iptables activity.
However, when using pgsql as output plugin ... performance is very
very sluggish. (~130-150 entries per second)

To enhance performance I am trying

modprobe ipt_ULOG nlbufsiz=65535 flushtimeout=1000

but this gives error : ipt_ULOG module not found.


On the same lines, I tried

modprobe ipt_NFLOG nlbufsiz=65535 flushtimeout=1000
It didnt give any error !!!

But still there is no increase in performance.
Are these values effective?

I am also using  --nflog-threshold 50 in iptables rule.

I am setting buffer_size as
netlink_socket_buffer_size=104857600
netlink_socket_buffer_maxsize=1048576000

When running ulog, it gives message of setting buffer size as
21708600. Though it didnt give any message like
"ulogd_inppkt_NFLOG.c:443 We are losing events, increasing buffer size
to xxxxxx"
but again why it is only setting buffer size as 21708600 though I have
set in config as 104857600?
