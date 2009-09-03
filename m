From: JiSheng Zhang <jszhang3@gmail.com>
Subject: disable_irq in ndo_poll_controller
Date: Thu, 3 Sep 2009 15:46:22 +0800
Message-ID: <2df346410909030046r1aeb319fw630174cfe8746502@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f176.google.com ([209.85.223.176]:40409 "EHLO
	mail-iw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbZICHwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 03:52:50 -0400
Received: by iwn6 with SMTP id 6so647416iwn.5
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 00:52:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

I found that there are three disable irq method in nicard drivers
ndo_poll_controller implementation :
1.disable_irq
2.loacle_irq_save
3.program nicard's register

why need disable irq in ndo_poll_controller?
Is all the three method equivalent?
Now I'm adding netconsole support to nic of our soc, which can I take
from the tree method?

Thanks in advance,
Jisheng
