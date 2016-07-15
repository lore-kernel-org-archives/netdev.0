From: Petri Gynther <pgynther@google.com>
Subject: Question on IPv6 default route metrics
Date: Fri, 15 Jul 2016 13:42:27 -0700
Message-ID: <CAGXr9JGHh3zMW2+tE_Hrddkz=Z3+UqN3XXUQqQZ80yWmuj+q=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35054 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbcGOUm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 16:42:29 -0400
Received: by mail-vk0-f42.google.com with SMTP id w127so112390496vkh.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 13:42:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev:

I have the same question as Jan in his original thread:
http://lkml.iu.edu/hypermail/linux/kernel/1108.3/01897.html

If a Linux device has multiple IPv6 default routes (e.g. via eth0 and
wlan0), they all currently have the same metric 1024.

But, wired route is normally preferred. So, it should have a lower metric.

It is my understanding that the kernel currently sets this default
route metric to 1024 when it receives a IPv6 router advertisement on a
link.

Is there any way to control the default route metric value on a
per-interface basis, i.e. router advertisements received on eth0 will
get metric 1024, and router advertisements received on wlan0 will get
metric, say, 1028?
