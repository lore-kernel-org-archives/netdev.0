From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] micrel: add support for KSZ8041RNLI
Date: Thu, 12 Dec 2013 00:28:47 +0300
Message-ID: <52A8D90F.9090002@cogentembedded.com>
References: <201312100220.42153.sergei.shtylyov@cogentembedded.com> <20131211.135841.1810559740815410070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20131211.135841.1810559740815410070.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/11/2013 09:58 PM, David Miller wrote:

>> Renesas R-Car development boards use KSZ8041RNLI PHY which for some reason has
>> ID of 0x00221537 that is not documented for KSZ8041-family PHYs and does not
>> match the  documented ID of  0x0022151x (where 'x' is the revision).  We have
>> to add the new #define PHY_ID_* and new ksphy_driver[] entry, almost the same
>> as KSZ8041 one, differing only in the 'phy_id' and 'name' fields.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> This patch is atop of DaveM's 'net-next.git' repo.

> Since this is just a simple device ID addition, I applied this to
> 'net', thanks.

    Hm, thanks, of course. But I don't see much difference w/my 'sh_eth' 
driver patch adding support for R8A7791 which you've queued for 3.14. Oh, 
well, not that it matters much...

WBR, Sergei

