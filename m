From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] RPS: Sparse connection optimizations
Date: Wed, 02 May 2012 06:12:48 +0200
Message-ID: <1335931968.22133.47.camel@edumazet-glaptop>
References: <1335607805-735-1-git-send-email-dczhu@mips.com>
	 <1335614156.2900.66.camel@edumazet-glaptop>  <4FA0B337.1070401@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58290 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab2EBEMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 00:12:53 -0400
Received: by wgbdr13 with SMTP id dr13so196809wgb.1
        for <netdev@vger.kernel.org>; Tue, 01 May 2012 21:12:52 -0700 (PDT)
In-Reply-To: <4FA0B337.1070401@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-02 at 12:08 +0800, Deng-Cheng Zhu wrote:

> Unfortunately, on the Malta platform, NIC irqs are not suitable for SMP
> IRQ affinity -- they are based on XT-PIC. However, I did do some RPS
> tests where different CPU masks were assigned to the 2 NICs. And the
> throughput *WAS* better than that of assigning the same mask to NICs.
> But the problem addressed in this patch *STILL* exists -- hash indexing
> causes imbalance across CPUs in the case of sparse connections.

You mean your two NIC irqs are handled by CPU0 and this cant be
changed ?

That really is bad.
