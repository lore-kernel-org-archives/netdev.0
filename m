From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Something hitting my total number of connections to the server
Date: Mon, 14 Aug 2017 14:37:48 +0530
Message-ID: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:37524 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdHNJHu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 05:07:50 -0400
Received: by mail-pg0-f45.google.com with SMTP id y129so43484578pgy.4
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 02:07:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have centos 7.3 (Kernel 3.10) running on a server with 128GB RAM and
2 x 10 Core Xeon Processor.
I have hosted a webserver on it and enabled ssh for remote maintenance.
Previously it was running on Centos 6.3.
After upgrading to CentOS 7.3, occasionally (probably when number of
hits are more on the server), I am not able to create new connections
(neither on web nor on ssh). Existing connections keeps on running
fine.

I did packet capturing using tcpdump to understand if its some
intermediate network issue.
What I found was the server is not replying for new SYN requests.

So it's clear that its not at all application issue. Also, there are
no logs in applications logs for any connections dropped, if any.

I check my firewall rules if there is some rate limiting imposed.
There is nothing in there.

I check tc, if by mistake some rate limiting is imposed. There is
nothing in there too.

I have increased noOfFiles to 1000000 and other sysctl parameters, but
the issue is still there.

Has anybody experienced the same?

How to go about? Anybody ... Please Help!!!
