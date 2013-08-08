From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:ethernet:korina.c Removed IRQF_DISABLED
Date: Thu, 08 Aug 2013 14:20:54 -0700 (PDT)
Message-ID: <20130808.142054.1541424422807503741.davem@davemloft.net>
References: <1375989649-7252-1-git-send-email-kumargauravgupta3@gmail.com>
	<20130808210918.GE5502@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumargauravgupta3@gmail.com, emilio@elopez.com.ar,
	mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130808210918.GE5502@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 9 Aug 2013 00:09:18 +0300

> On Fri, Aug 09, 2013 at 12:50:49AM +0530, Kumar Gaurav wrote:
>> Removed IRQF_DISABLED as it's no-op and should be removed
>> 
> 
> What?  No, that doesn't sound right.

The IRQ layer completely ignores the flag for several releases
now, it's a complete no-op as his commit message so adequately
states.

So what's the problem again? :-)
