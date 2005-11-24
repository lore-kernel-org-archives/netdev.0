From: Avi Kivity <avi@argo.co.il>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Thu, 24 Nov 2005 17:24:34 +0200
Message-ID: <4385DB32.7010605@argo.co.il>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com> <4384E7F2.2030508@pobox.com> <20051123223007.GA5921@wotan.suse.de> <20051124001700.GC14246@kvack.org> <20051124065037.GZ20775@brahms.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>, Jeff Garzik <jgarzik@pobox.com>,
	Andrew Grover <andrew.grover@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751374AbVKXPYi@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20051124065037.GZ20775@brahms.suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

>>Don't forget that there are benefits of not polluting the cache with the 
>>traffic for the incoming skbs.
>>    
>>
>
>Is that a general benefit outside benchmarks? I would expect
>most real programs to actually do something with the data
>- and that usually involves needing it in cache.
>
>  
>
As an example, an NFS server reads some data pages using iSCSI and sends 
them using NFS/TCP (or vice versa).

>>In the I/O AT case it might make sense to do a few prefetch()es of the 
>>userland data on the return-to-userspace code path.  
>>    
>>
>
>Some prefetches for user space might be a good idea yes
>
>  
>
As long as they can be turned off. Not all usespace applications want to 
touch the data immediately.
