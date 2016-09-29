From: Marcel Holtmann <marcel@holtmann.org>
Subject: net-next tree broken with CONFIG_NETFILTER_INGRESS=n
Date: Thu, 29 Sep 2016 08:23:03 +0200
Message-ID: <E3004E95-F774-457E-9BA8-FA29A72BE035@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:42724 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbcI2GXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 02:23:07 -0400
Received: from marcel-macbook.fritz.box (dslb-178-003-132-147.178.003.pools.vodafone-ip.de [178.3.132.147])
        by mail.holtmann.org (Postfix) with ESMTPSA id 1BE91CF351
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 08:26:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the net-next tree is broken since a few days now when CONFIG_NETFILTER_INGRESS=n is set.

  CC      net/netfilter/core.o
In file included from ./include/linux/linkage.h:4:0,
                 from ./include/linux/kernel.h:6,
                 from net/netfilter/core.c:10:
net/netfilter/core.c: In function ‘nf_set_hooks_head’:
net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
                              ^
./include/linux/compiler.h:299:17: note: in definition of macro ‘WRITE_ONCE’
  union { typeof(x) __val; char __c[1]; } __u = \
                 ^
Regards

Marcel
