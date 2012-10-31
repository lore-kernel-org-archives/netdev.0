From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/9] use this_cpu_ptr instead of  per_cpu_ptr(p,
 smp_processor_id())
Date: Wed, 31 Oct 2012 17:28:56 +0000
Message-ID: <0000013ab7de641e-c975be0c-e85b-4705-8f02-e25b2d4a0ac2-000000@email.amazonses.com>
References: <509109D2.9030209@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <509109D2.9030209@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2012, Shan Wei wrote:

> this_cpu_ptr is faster than per_cpu_ptr(p, smp_processor_id()).
> The latter helper needs to find the offset for current cpu,
> and needs more assembler instructions which objdump shows in following.

The code is shorter and that helps but note that the main effect is that
memory accesses are reduced.
