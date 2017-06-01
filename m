From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 5/5] net: dsa: factor skb freeing on xmit
Date: Thu, 1 Jun 2017 13:14:18 -0700
Message-ID: <7aa57651-0bdb-730e-2dff-f0b2d2e94532@gmail.com>
References: <20170601200715.8438-1-vivien.didelot@savoirfairelinux.com>
 <20170601200715.8438-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170601200715.8438-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/2017 01:07 PM, Vivien Didelot wrote:
> As of a86d8becc3f0 ("net: dsa: Factor bottom tag receive functions"),
> the rcv caller frees the original SKB in case or error.
> 
> Be symmetric with that and make the xmit caller do the same.
> 
> At the same time, fix the checkpatch NULL comparison check:
> 
>         CHECK: Comparison to NULL could be written "!nskb"
>     #208: FILE: net/dsa/tag_trailer.c:35:
>     +	if (nskb == NULL)
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

I must have not read the patch correctly the first time, because my
objection no longer stands, this looks much cleaner now, thanks!
-- 
Florian
