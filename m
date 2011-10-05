From: Eduardo Panisset <eduardo.panisset@gmail.com>
Subject: RCU list entry in ipv6_chk_addr function
Date: Wed, 5 Oct 2011 15:16:43 -0300
Message-ID: <CADsjWXR2WffKKHxom16i01_BbCWBBQWLdQUz_vEnp_enuFoEdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:56272 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933193Ab1JESQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 14:16:43 -0400
Received: by yxl31 with SMTP id 31so1841855yxl.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 11:16:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I was looking over ipv6 implementation for kernel 3.0.4.

Shouldn't "hlist_for_each_entry_rcu_bh" be used instead of
"hlist_for_each_entry_rcu" in the function ipv6_chk_addr (file
net/ipv6/addrconf.c) ?

Best Regards,
Eduardo Panisset.
