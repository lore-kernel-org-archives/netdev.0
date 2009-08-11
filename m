From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Subject: a question on net_device struct
Date: Tue, 11 Aug 2009 23:57:31 +0900
Message-ID: <2014bcab0908110757q5b255dcdm497414d04810c281@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f175.google.com ([209.85.210.175]:47140 "EHLO
	mail-yx0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827AbZHKO5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 10:57:35 -0400
Received: by yxe5 with SMTP id 5so4744849yxe.33
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 07:57:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. I have a question while I read the codes in net/core of Linux 2.6.30.4.

'net_device' struct defined in include/linux/netdevice.h has a field
'operstate'.
Is a 'operstate' field is protected by 'dev_base_lock'?

At set_operstate() in net/core/rtnetlink.c, it seems that dev->operstate
is protected by write_lock_bh(&dev_base_lock).
But, in other codes, the read operations to dev->operstate are not
consistently protected by read_lock_bh(&dev_base_lock).

Thank you.

Sincerely
Shin Hong
