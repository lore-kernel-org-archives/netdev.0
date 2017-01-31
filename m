From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] sfc: fix an off-by-one compare on an array
 size
Date: Tue, 31 Jan 2017 12:26:02 -0500 (EST)
Message-ID: <20170131.122602.1280692272369236886.davem@davemloft.net>
References: <20170131163002.20882-1-colin.king@canonical.com>
        <0a30579a-b0e4-11cd-8613-735c143061e1@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: colin.king@canonical.com, linux-net-drivers@solarflare.com,
        bkenward@solarflare.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: ecree@solarflare.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <0a30579a-b0e4-11cd-8613-735c143061e1@solarflare.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 31 Jan 2017 16:37:10 +0000

> On 31/01/17 16:30, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> encap_type should be checked to see if it is greater or equal to
>> the size of array map to fix an off-by-one array size check. This
>> fixes an array overrun read as detected by static analysis by
>> CoverityScan, CID#1398883 ("Out-of-bounds-read")
>>
>> Fixes: 9b41080125176841e ("sfc: insert catch-all filters for encapsulated traffic")
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Good catch.
> 
> Acked-by: Edward Cree <ecree@solarflare.com>

Applied, thanks everyone.
