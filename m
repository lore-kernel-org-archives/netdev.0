From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Fri, 15 Aug 2008 22:16:43 +0200
Message-ID: <48A5E42B.8060903@gmail.com>
References: <20080815190905.M56388@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:25177 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbYHOUQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 16:16:48 -0400
Received: by yx-out-2324.google.com with SMTP id 8so837018yxm.1
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 13:16:47 -0700 (PDT)
In-Reply-To: <20080815190905.M56388@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 08/15/2008 09:09 PM:

> Aug 15 21:59:54 192.168.20.66 [ 1123.800035] BUG: unable to handle kernel
> Aug 15 21:59:54 192.168.20.66 NULL pointer dereference
> Aug 15 21:59:54 192.168.20.66 at 00000004
> Aug 15 21:59:54 192.168.20.66 [ 1123.800035] IP:
> Aug 15 21:59:54 192.168.20.66 [<c0272579>] qdisc_dequeue_head+0x29/0x3d


Could you add some details like:
- device(eth, ppp, ifb...), net driver(s) on that device,
- types of filters, actions on the path to this tbf queue,
- were there any config changes done around the time when this happened?

Thanks,
Jarek P.
