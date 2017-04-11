From: zhong jiang <zhongjiang@huawei.com>
Subject: Re: Page allocator order-0 optimizations merged
Date: Tue, 11 Apr 2017 09:54:39 +0800
Message-ID: <58EC375F.5040800@huawei.com>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org> <20170301144845.783f8cad@redhat.com> <58EB9754.3090202@huawei.com> <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Mel Gorman <mgorman@techsingularity.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:5357 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751101AbdDKB4B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 21:56:01 -0400
In-Reply-To: <20170410151051.n4lytmha4tqh4l3t@techsingularity.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/4/10 23:10, Mel Gorman wrote:
> On Mon, Apr 10, 2017 at 10:31:48PM +0800, zhong jiang wrote:
>> Hi, Mel
>>
>>      The patch I had test on arm64. I find the great degradation. I test it by micro-bench.
>>     The patrly data is as following.  and it is stable.  That stands for the allocate and free time. 
>>     
> What type of allocations is the benchmark doing? In particular, what context
> is the microbenchmark allocating from? Lastly, how did you isolate the
> patch, did you test two specific commits in mainline or are you comparing
> 4.10 with 4.11-rcX?
>
 Hi, Mel

   benchmark adopt  0 order allocation.  just insmod module  allocate  memory by alloc_pages.
   it is not interrupt context.  I test the patch in linux 4.1 stable. In x86 , it have 10% improve.
   but in arm64,  it have great degradation.  

  Thanks
  zhongjiang
