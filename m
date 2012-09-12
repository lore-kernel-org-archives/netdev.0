From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [v2 PATCH 2/2] netprio_cgroup: Use memcpy instead of the for-loop
 to copy priomap
Date: Wed, 12 Sep 2012 13:54:05 +0530
Message-ID: <505046A5.1050009@linux.vnet.ibm.com>
References: <20120912060741.11037.37347.stgit@srivatsabhat.in.ibm.com> <20120912060747.11037.42623.stgit@srivatsabhat.in.ibm.com> <20120912.034901.184817520125489015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, David.Laight@aculab.com,
	john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com, mark.d.rustad@intel.com,
	lizefan@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120912.034901.184817520125489015.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/12/2012 01:19 PM, David Miller wrote:
> From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
> Date: Wed, 12 Sep 2012 11:37:47 +0530
> 
>> +		memcpy(new_priomap->priomap, old_priomap->priomap,
>> +			old_priomap->priomap_len *
>> +					sizeof(old_priomap->priomap[0]));
> 
> This argument indentation is ridiculous.  Try:
> 
> 		memcpy(new_priomap->priomap, old_priomap->priomap,
> 		       old_priomap->priomap_len *
> 		       sizeof(old_priomap->priomap[0]));
> 
> Using TABs exclusively for argumentat indentation is not the goal.
> 
> Rather, lining the arguments up properly so that they sit at the first
> column after the first line's openning parenthesis is what you should
> be trying to achieve.

OK, will fix it, thanks!

> 
> And ignoring whatever stylistic convention we may or may not have, I
> find it impossibly hard to believe that the code quoted above looks
> good even to you.
>

On second thoughts, I think the memcpy in this case will actually be worse
since it will copy the contents in chunks of smaller size than the for-loop.

Or, did you mean to say that this code is plain wrong for some reason?

Regards,
Srivatsa S. Bhat
