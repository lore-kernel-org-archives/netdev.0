From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] sh_eth: ensure pm_runtime cannot suspend the device
 during init
Date: Sat, 29 Mar 2014 17:52:07 +0400
Message-ID: <5336D007.1090709@cogentembedded.com>
References: <5335CCBF.8030606@codethink.co.uk>	<20140328.160024.136488246522581222.davem@davemloft.net>	<5335E53C.6020208@cogentembedded.com> <20140328.171836.1899283620390720935.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@lists.codethink.co.uk,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	laurent.pinchart+renesas@ideasonboard.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140328.171836.1899283620390720935.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 29-03-2014 1:18, David Miller wrote:

>>>> I thought it was against the net next tree, given the number of
>>>> patches that are currently being applied to the sh_eth driver.

>>> Fair enough, applied to net-next, thanks!

>>     It probably makes sense to queue this for the stable kernels as well.

> Sorry, that's not how this works.

> If it's good enough for -stable, meaning that users are activly hitting
> the problem and it's a serious bug, then it's good enough for 'net'
> and should have been submitted against 'net'.

    I thought that at this point only regression fixes are good for 'net'.
Although, this can be considered a regression too -- since addition of runtime 
PM support back in 2009.

WBR, Sergei

