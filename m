From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 6 Jun 2014 08:21:39 -0500
Message-ID: <5391C063.3010207@amd.com>
References: <20140606164543.6c5bbe67@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606164543.6c5bbe67@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2014 01:45 AM, Stephen Rothwell wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc allyesconfig)
> failed like this:
>
>
> drivers/net/ethernet/amd/xgbe/xgbe-dev.c:119:25: fatal error: asm/cputype.h: No such file or directory
>   #include <asm/cputype.h>
>                           ^

I accidentally left this in from driver debugging and it is not
necessary.  Patch to follow.

Tom

>
> Caused by commit c5aa9e3b8156 ("amd-xgbe: Initial AMD 10GbE platform driver").
>
> I reverted commit 54a4ca8e3730 ("Merge branch 'amd-xgbe'") for today.
>
