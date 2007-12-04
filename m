From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 3/3] [UDP6]: Counter increment on BH mode
Date: Tue, 04 Dec 2007 11:50:55 +0800
Message-ID: <4754CE9F.3060506@cn.fujitsu.com>
References: <474F7EE8.2040009@cn.fujitsu.com> <474F8255.5060501@cn.fujitsu.com> <20071130111949.GB28277@gerrit.erg.abdn.ac.uk> <20071201015438.GC26895@gondor.apana.org.au> <4753AE07.1040906@cn.fujitsu.com> <20071203113935.GA25124@gondor.apana.org.au> <20071203114912.GA4425@ms2.inr.ac.ru> <20071203115435.GA4202@gondor.apana.org.au> <20071203131723.GA30312@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:52971 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbXLDDxq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 22:53:46 -0500
In-Reply-To: <20071203131723.GA30312@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-3 21:17:
> On Mon, Dec 03, 2007 at 10:54:35PM +1100, Herbert Xu wrote:
> diff --git a/include/net/snmp.h b/include/net/snmp.h
> index ea206bf..9444b54 100644
> --- a/include/net/snmp.h
> +++ b/include/net/snmp.h
> @@ -23,6 +23,7 @@
>  
>  #include <linux/cache.h>
>  #include <linux/snmp.h>
> +#include <linux/smp.h>

It's no need to include smp.h?

--
WCN

