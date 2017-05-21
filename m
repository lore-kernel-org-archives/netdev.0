From: Manohar Kumar <forwardinglnx@gmail.com>
Subject: Deleting a dynamic mac entry..
Date: Sat, 20 May 2017 19:28:22 -0700
Message-ID: <CA+N+6-xY7+coc6zFqzP665WMhbGFFMHOfre9wNxRAcSF2Bthzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35495 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbdEUC2Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 22:28:24 -0400
Received: by mail-qt0-f182.google.com with SMTP id v27so81632160qtg.2
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 19:28:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

In 3.19 the following bridge fdb command to delete a dynamically
learned entry fails..

root@net-3:~# bridge fdb show | grep 02:42:0a:ff:00:06
02:42:0a:ff:00:06 dev vxlan0 master br0
root@net-3:~# bridge fdb del 02:42:0a:ff:00:06 dev vxlan0 master
RTNETLINK answers: No such file or directory

It works in 4.4.

Can someone please point to the patch that made this change ?

In kernels without this patch is there an alternative to delete
(actually I want to do it programmatically) dynamic mac entries ?
