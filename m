From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 07 May 2012 09:22:20 +0200
Message-ID: <1336375340.3752.2242.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com> <1336117669.3752.49.camel@edumazet-glaptop>
	 <4FA770DA.6000104@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44712 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab2EGHWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 03:22:25 -0400
Received: by eaaq12 with SMTP id q12so1291919eaa.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 00:22:24 -0700 (PDT)
In-Reply-To: <4FA770DA.6000104@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 14:51 +0800, Deng-Cheng Zhu wrote:

> This is not about arch, it's about system design. Even with IRQ affinity
> working, for single queue NICs, RPS still has its value in this test.
> 

Post your numbers when proper affinities are done.

Having several cpus fighting on output path for qdisc/device lock is a
killer. Extra IPI are not worth the pain.
