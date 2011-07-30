From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Sat, 30 Jul 2011 11:55:20 +0200
Message-ID: <20110730095520.GA12248@electric-eye.fr.zoreil.com>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com> <1311931816.2843.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rui Ueyama <rui314@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46277 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab1G3KLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2011 06:11:18 -0400
Content-Disposition: inline
In-Reply-To: <CACKH++afaAaa7a6ViYjo_PjpF1bXYtOuJaa-4umEOSVgW1+g3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rui Ueyama <rui314@gmail.com> :
> The result of benchmark looks good.

So far the overall improvement is below 2% (upper bound, without calculator).

And the result of benchmark without tcpdump looks strange.

> A simple benchmark that sends 10M UDP
> packets to lo took 76.24 seconds on average on Core 2 Duo L7500@1.6GHz.when
> tcpdump is running. With this patch it took 75.41 seconds, which means we save
> 80ns for each packet on that processor.

You forgot to analyze the figures without tcpdump.

> I think converting the VM to threaded code is low hanging fruit, even
> if we'd have JIT compilers for popular architectures. Most of the lines
> in my patch are indentation change, so the actual change is not big.

Without further data nor plan for future / possible improvements, it
could be said a gratuitous rewrite too.

-- 
Ueimor
