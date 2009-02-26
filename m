From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 10:56:16 +0000
Message-ID: <20090226105616.GA5754@ff.dom.local>
References: <20090226093902.GA12753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Romanenko <ash@sevsky.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:46308 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbZBZK40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 05:56:26 -0500
Received: by fxm24 with SMTP id 24so441688fxm.37
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 02:56:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090226093902.GA12753@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2009 10:39, Herbert Xu wrote:
> Denis Romanenko <ash@sevsky.net> wrote:
>> I have high loaded router - about 1.2 Gbps
>>
>> after reboot on new kernel - 2.6.27.17 i have messages in dmesg
>>
>> WARNING: at kernel/softirq.c:136 local_bh_enable+0x36/0xab()
> 
> So somebody disabled the IRQs on us, the question is who?

netconsole. It's a known issue, btw.

Cheers,
Jarek P.
