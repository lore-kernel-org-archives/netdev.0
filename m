From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH] sh_eth: fix SH7619/771x support
Date: Wed, 4 Jun 2014 11:20:33 +0900
Message-ID: <538E8271.6040406@renesas.com>
References: <201406032342.27160.sergei.shtylyov@cogentembedded.com>	<538E69B0.1030706@renesas.com> <20140603.190229.1248289002649714904.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>,
	<linux-sh@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140603.190229.1248289002649714904.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

(2014/06/04 11:02), David Miller wrote:
> From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Date: Wed, 4 Jun 2014 09:34:56 +0900
> 
>> (2014/06/04 4:42), Sergei Shtylyov wrote:
>>> Commit 4a55530f38e4 (net: sh_eth: modify the definitions of register) managed
>>> to leave out the E-DMAC register entries in sh_eth_offset_fast_sh3_sh2[], thus
>>> totally breaking SH7619/771x support.  Add the missing entries using  the data
>>> from before that commit.
>>>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>  ...
>> I checked sh7710 and sh7619 datasheet, but they don't have RPADIR register.
>> Since I would like to check a datasheet you looked into, would you tell me about this?
> 
> I think what Sergei simply did is take what was used for register offsets
> before the mentioned commits.
> 
> The RPADIR register write is guarded by "mdp->cd->rpadir" being non-zero,
> so his change is very safe.

Thank you for the reply. I understood it.

Since I checked all of the registers offset in this patch and they are good:
Acked-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Best regards,
Yoshihiro Shimoda
