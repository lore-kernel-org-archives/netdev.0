From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/9] net: core: use this_cpu_ptr per-cpu helper
Date: Mon, 19 Nov 2012 19:00:21 -0500 (EST)
Message-ID: <20121119.190021.1729303717477399876.davem@davemloft.net>
References: <50A1A7BA.5000507@gmail.com>
	<50A5FB69.8000907@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cl@linux-foundation.org, htejun@gmail.com
To: shanwei88@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A5FB69.8000907@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <shanwei88@gmail.com>
Date: Fri, 16 Nov 2012 16:38:01 +0800

> Shan Wei said, at 2012/11/13 9:51:
>> From: Shan Wei <davidshan@tencent.com>
>> 
>> flush_tasklet is a struct, not a pointer in percpu var.
>> so use this_cpu_ptr to get the member pointer.
>> 
>> Signed-off-by: Shan Wei <davidshan@tencent.com>
>> Reviewed-by: Christoph Lameter <cl@linux.com>
> 
> David Miller,  would you like to pick it up to your net-next tree?

Applied.
