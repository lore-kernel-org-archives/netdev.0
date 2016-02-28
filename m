From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 01/13] RDS: Drop stale iWARP RDMA transport
Date: Sun, 28 Feb 2016 02:11:25 -0800
Message-ID: <56D2C7CD.3020009@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
 <1456625990-4739-2-git-send-email-santosh.shilimkar@oracle.com>
 <20160228090547.GA6671@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160228090547.GA6671@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2/28/16 1:05 AM, Christoph Hellwig wrote:
> On Sat, Feb 27, 2016 at 06:19:38PM -0800, Santosh Shilimkar wrote:
>> RDS iWarp support code has become stale and non testable. As
>> indicated earlier, am dropping the support for it.
>>
>> If new iWarp user(s) shows up in future, we can adapat the RDS IB
>> transprt for the special RDMA READ sink case. iWarp needs an MR
>> for the RDMA READ sink.
>
> Please take a look at the RDMA RW API series I posted yesterday - if
> you can adopt RDS to that you should get iWarp support for free.
>
Will have a look. Thanks for the pointer.

> But having two different codebases for IB/RoCE vs iWarp was always a bad
> idea, so great to see the second one retired!
>
> Acked-by: Christoph Hellwig <hch@lst.de>
>
Thanks !!
