From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: dst in not an array
Date: Thu, 03 Aug 2017 09:30:27 -0700 (PDT)
Message-ID: <20170803.093027.593710981203608573.davem@davemloft.net>
References: <20170802194825.29002-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170802194825.29002-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  2 Aug 2017 15:48:25 -0400

> It's been a while now since ds->dst is not an array anymore, but a
> simple pointer to a dsa_switch_tree.
> 
> Fortunately, SF2 does not support multi-chip and thus ds->index is
> always 0.
> 
> This patch substitutes 'ds->dst[ds->index].' with 'ds->dst->'.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
