From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: fix SH7619/771x support
Date: Tue, 03 Jun 2014 19:02:29 -0700 (PDT)
Message-ID: <20140603.190229.1248289002649714904.davem@davemloft.net>
References: <201406032342.27160.sergei.shtylyov@cogentembedded.com>
	<538E69B0.1030706@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <538E69B0.1030706@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Wed, 4 Jun 2014 09:34:56 +0900

> (2014/06/04 4:42), Sergei Shtylyov wrote:
>> Commit 4a55530f38e4 (net: sh_eth: modify the definitions of register) managed
>> to leave out the E-DMAC register entries in sh_eth_offset_fast_sh3_sh2[], thus
>> totally breaking SH7619/771x support.  Add the missing entries using  the data
>> from before that commit.
>> 
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
 ...
> I checked sh7710 and sh7619 datasheet, but they don't have RPADIR register.
> Since I would like to check a datasheet you looked into, would you tell me about this?

I think what Sergei simply did is take what was used for register offsets
before the mentioned commits.

The RPADIR register write is guarded by "mdp->cd->rpadir" being non-zero,
so his change is very safe.
