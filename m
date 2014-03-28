From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Fri, 28 Mar 2014 17:18:36 -0400 (EDT)
Message-ID: <20140328.171836.1899283620390720935.davem@davemloft.net>
References: <5335CCBF.8030606@codethink.co.uk>
	<20140328.160024.136488246522581222.davem@davemloft.net>
	<5335E53C.6020208@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@lists.codethink.co.uk,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	laurent.pinchart+renesas@ideasonboard.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5335E53C.6020208@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 29 Mar 2014 00:10:20 +0300

> Hello.
> 
> On 03/28/2014 11:00 PM, David Miller wrote:
> 
>>> I thought it was against the net next tree, given the number of
>>> patches that are currently being applied to the sh_eth driver.
> 
>> Fair enough, applied to net-next, thanks!
> 
>    It probably makes sense to queue this for the stable kernels as well.

Sorry, that's not how this works.

If it's good enough for -stable, meaning that users are activly hitting
the problem and it's a serious bug, then it's good enough for 'net'
and should have been submitted against 'net'.
