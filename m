From: tej parkash <parkash.tej@gmail.com>
Subject: netlink_route kernel data dump size increased
Date: Wed, 19 Aug 2015 23:41:14 +0530
Message-ID: <CAM1L+iBqypLJi2qD3Ncs_L+Lyi=ozRSciZvhBL5OzqjPFGfprg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35351 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbHSSLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:11:54 -0400
Received: by pacgr6 with SMTP id gr6so8186256pac.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 11:11:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All,

We are running application on Linux Kernel 3.10 to collect network
interface information using  NETLINK_ROUTE protocol. earlier (kernel
2.6.32) we were having 8K buffer allocated to collect all data but
with new kernel (3.10) we are seeing read socket error, as buffer size
is not sufficient for all network dump data.

We want to understand that if the userspace buffer limit increased to
16K or we need some other mechanism to collect the data in 8K chuck.
or Is there any other way application can use NETLINK_ROUTE  protocol,
so that it will not break the application if data size gets increased
in future.

I did some some browsing and found some link but they were not very conclusive.
http://www.spinics.net/lists/netdev/msg162185.html

Appreciate for any kind of help or pointers here


Thanks
Tej
