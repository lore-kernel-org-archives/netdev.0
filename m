From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] wan/sdla section fixes
Date: Mon, 12 Jun 2006 19:50:22 +0200
Message-ID: <m3d5de461t.fsf@defiant.localdomain>
References: <20060608203616.16796ec3.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, mike.mclagan@linux.org,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:16769 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1750842AbWFLRuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 13:50:23 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060608203616.16796ec3.rdunlap@xenotime.net> (Randy Dunlap's message of "Thu, 8 Jun 2006 20:36:16 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

"Randy.Dunlap" <rdunlap@xenotime.net> writes:

> Priority: tossup.
> netdev->set_config can be called at any time, so these references
> to __initdata would be a real problem.
> However, problem has not been observed AFAIK.
>
> Fix section mismatch warnings:
> WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1b8e) and 'sdla_stats'
> WARNING: drivers/net/wan/sdla.o - Section mismatch: reference to .init.data: from .text between 'sdla_set_config' (at offset 0x1e76) and 'sdla_stats'

Is sdla.c still in use? I remember someone mentioned that Sangoma
drivers are now outside the kernel but I don't know how do they
relate to sdla.c and friend(s).

>  static const char* version = "SDLA driver v0.30, 12 Sep 1996,
> mike.mclagan@linux.org";

1996 doesn't look encouraging but it may be misleading.
-- 
Krzysztof Halasa
