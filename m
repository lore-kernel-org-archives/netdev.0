From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_fastopen unaligned access complaints on
 sparc
Date: Thu, 12 Jan 2017 16:58:50 -0500 (EST)
Message-ID: <20170112.165850.1803282665815813853.davem@davemloft.net>
References: <1484256990.13165.6.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170112.164731.720625943370044951.davem@davemloft.net>
        <a24f1f0e-457b-0316-b545-fe1362bd7dbe@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, rob.gardner@oracle.com,
        netdev@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a24f1f0e-457b-0316-b545-fe1362bd7dbe@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Thu, 12 Jan 2017 13:58:10 -0800

> 
> 
> On 1/12/2017 1:47 PM, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 12 Jan 2017 13:36:30 -0800
>>
>>> val should be an union, so that proper alignment is enforced by one
>>> member.
>>
>> Sure, annotating the type so that it is aligned correctly makes
>> sense.
>>
> 
> ... and we should change the offending pointer assignment as well.  I
> can use this and respin a v2 if we're happy with this solution.

I am.
