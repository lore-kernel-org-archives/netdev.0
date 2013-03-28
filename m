From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: network namespace + bridge visibility
Date: Fri, 29 Mar 2013 00:19:18 +0600
Message-ID: <CAEmTpZFp1_NiOJOUip2jwBxM5s5ogRDUut2D27Uy1qi=dW6SLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f44.google.com ([209.85.216.44]:37707 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab3C1STT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:19:19 -0400
Received: by mail-qa0-f44.google.com with SMTP id o13so1715722qaj.10
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 11:19:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

==========================
mmarkk@imac:~# brctl addbr qwe
mmarkk@imac:~# unshare -n /bin/bash
root@imac:~# ip link
14: lo: <LOOPBACK> mtu 16436 qdisc noop state DOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
root@imac:~# brctl show
bridge name bridge id STP enabled interfaces
qwe 8000.000000000000 no
root@imac:~# brctl delbr qwe
bridge qwe doesn't exist; can't delete it
=============================

So, network device is not available, but present in list of bridges.
This is the bug, as I think.

Reproducible in linux kernels 3.8.2 and 3.2.0

--
Segmentation fault
