From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: [net PATCH 1/1] qlge:Changing netdev msg level to default debug
Date: Wed, 25 Jan 2012 10:44:14 +0530
Message-ID: <CANX6DakVF8PC8xrmRU1KvBqqJ8g79_Ev1ZFU-APNyPy-7T8Q_Q@mail.gmail.com>
References: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
	<20120124.153837.905415925299369179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ron.mercer@qlogic.com, Dept_NX_Linux_NIC_Driver@qlogic.com
To: netdev@vger.kernel.org, jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:32815 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab2AYFOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 00:14:16 -0500
Received: by wics10 with SMTP id s10so3499971wic.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 21:14:14 -0800 (PST)
In-Reply-To: <20120124.153837.905415925299369179.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Moving to a default of "3" makes no sense at all, express the default
> in the second argument of netif_msg_init(), not the first.

Yes, and i think that was the source of confusion for me.

>
> I'm not applying this patch, use other drivers such as tg3.c as a
> guide.
-- 
Thanks,
Viral Mehta
