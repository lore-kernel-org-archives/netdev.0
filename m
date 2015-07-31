From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [PATCH 08/15] drivers: net: Drop unlikely before IS_ERR(_OR_NULL)
Date: Fri, 31 Jul 2015 21:50:18 +0530
Message-ID: <20150731162018.GD899@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
 <ceb569d147977a4138a7dd334fe7b9b0efdac8ac.1438331416.git.viresh.kumar@linaro.org>
 <55BB8E7B.7050307@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linaro-kernel@lists.linaro.org,
	linux-kernel@vger.kernel.org, open list:
	TI NETCP ETHERNET DRIVER <netdev@vger.kernel.org>,
	Wingman Kwok <w-kwok2@ti.com>, ;
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55BB8E7B.7050307@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31-07-15, 11:04, Murali Karicheri wrote:
> On 07/31/2015 04:38 AM, Viresh Kumar wrote:
> >IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> >is no need to do that again from its callers. Drop it.
> >
> 
> IS_ERR_OR_NULL() is defined as
> 
> static inline bool __must_check IS_ERR_OR_NULL(__force const void *ptr)
> {
>         return !ptr || IS_ERR_VALUE((unsigned long)ptr);
> }
> 
> So the unlikely() applies only to second part. Wouldn't that be a
> problem for optimization?

This is what the first patch of the series does:

http://permalink.gmane.org/gmane.linux.kernel/2009151

-- 
viresh
