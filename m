From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Fri, 9 Nov 2012 20:12:06 +0000
Message-ID: <0000013ae6ccff86-695eb9f4-23b6-4196-a575-e12d05e1a659-000000@email.amazonses.com>
References: <509C688B.5010502@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509C688B.5010502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Nov 2012, Shan Wei wrote:

> v3 fix compile warning:
> net/xfrm/xfrm_ipcomp.c: In function 'ipcomp_alloc_tfms':
> net/xfrm/xfrm_ipcomp.c:285: warning: assignment from incompatible pointer type

Why exactly is the pointer type not compatible? Looks like we have a
problem here.
