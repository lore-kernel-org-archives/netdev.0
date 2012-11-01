From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Thu, 01 Nov 2012 17:00:56 +0800
Message-ID: <50923A48.1080906@gmail.com>
References: <509109F9.3030904@gmail.com> <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com> <20121101034136.GA27343@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, steffen.klassert@secunet.com,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121101034136.GA27343@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu said, at 2012/11/1 11:41:
> Please refer to the comment in the patch above.
> 
> But I think the patch is wrong anyway because it would introduce
> a warning, no?

yes, __this_cpu_ptr(or __this_cpu_read) is more reasonable 
which don't check preemption context.

> 
> Thanks,
> 
