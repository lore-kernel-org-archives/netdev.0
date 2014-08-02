From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Sat, 02 Aug 2014 15:33:37 -0700 (PDT)
Message-ID: <20140802.153337.1399638752235662112.davem@davemloft.net>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
	<20140731.132520.1889577477638334755.davem@davemloft.net>
	<20140801110246.GB17947@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@citrix.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	Ian.Campbell@citrix.com, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: wei.liu2@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801110246.GB17947@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Liu <wei.liu2@citrix.com>
Date: Fri, 1 Aug 2014 12:02:46 +0100

> On Thu, Jul 31, 2014 at 01:25:20PM -0700, David Miller wrote:
>> If you were to have a 64-slot TX queue, you ought to be able to handle
>> this theoretical 51 slot SKB.
> 
> There's two problems:
> 1. IIRC a single page ring has 256 slots, allowing 64 slots packet
>    yields 4 in-flight packets in worst case.
> 2. Older netback could not handle this large number of slots and it's
>    likely to deem the frontend malicious.
> 
> For #1, we don't actually care that much if guest screws itself by
> generating 64 slot packets. #2 is more concerning.

How many slots can the older netback handle?
