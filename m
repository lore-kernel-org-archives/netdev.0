From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Mon, 31 May 2010 08:22:12 +0800
Message-ID: <20100531002210.GA4388@host-a-55.ustcsz.edu.cn>
References: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
 <4C02A1F7.6030701@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:65227 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab0EaAV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 20:21:57 -0400
Received: by pzk42 with SMTP id 42so1392248pzk.4
        for <netdev@vger.kernel.org>; Sun, 30 May 2010 17:21:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4C02A1F7.6030701@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 30, 2010 at 01:35:51PM -0400, Jeff Garzik wrote:
>
>Have you verified this matches all architectures definition of readl()?
>

Hi Jeff,

Thanks for your question. Just browsed the kernel. ioread32() returns either 
unsigned int or u32 in all arches. There is no arch that uses unsigned long 
or something else.

Secondly, There's a bug if an arch returns unsigned long. What happen when 
programmers invoke sizeof(ioread32()) on 64-bit platforms?

--Junchang
