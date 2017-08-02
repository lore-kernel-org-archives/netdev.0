From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: dst in not an array
Date: Wed, 2 Aug 2017 12:55:12 -0700
Message-ID: <b44d5c57-64fd-db0f-b391-11e6eb7a2815@gmail.com>
References: <20170802194825.29002-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802194825.29002-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/02/2017 12:48 PM, Vivien Didelot wrote:
> It's been a while now since ds->dst is not an array anymore, but a
> simple pointer to a dsa_switch_tree.
> 
> Fortunately, SF2 does not support multi-chip and thus ds->index is
> always 0.
> 
> This patch substitutes 'ds->dst[ds->index].' with 'ds->dst->'.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
