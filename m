From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Fri, 16 Jul 2010 15:05:41 +0800
Message-ID: <AANLkTild5SQvt7Uw7AAV7BrrSdvPdoglgbm1uJQnigdM@mail.gmail.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>
	<1279204417.2118.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:55308 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935668Ab0GPHFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 03:05:42 -0400
Received: by iwn7 with SMTP id 7so1832271iwn.19
        for <netdev@vger.kernel.org>; Fri, 16 Jul 2010 00:05:41 -0700 (PDT)
In-Reply-To: <1279204417.2118.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> You should also compare the CPU usage.
>
> Ben.
>
Hi Ben,
I added options -c -C to netperf's command line. Result is as follows:
                    scheme 1    scheme 2    Imp.
Throughput:     683M        718M       5%
CPU usage:     47.8%       45.6%

That really surprised me because "top" command showed the CPU usage
was fluctuating between 0.5% and 1.5% rather that between 45% and 50%.

How can I get the exact CPU usage?

Thanks.

-- 
--Junchang
