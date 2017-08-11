From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: ksz: fix skb freeing
Date: Fri, 11 Aug 2017 13:57:25 -0700 (PDT)
Message-ID: <20170811.135725.67224099020250004.davem@davemloft.net>
References: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  9 Aug 2017 16:46:09 -0400

> The DSA layer frees the original skb when an xmit function returns NULL,
> meaning an error occurred. But if the tagging code copied the original
> skb, it is responsible of freeing the copy if an error occurs.
> 
> The ksz tagging code currently has two issues: if skb_put_padto fails,
> the skb copy is not freed, and the original skb will be freed twice.
> 
> To fix that, move skb_put_padto inside both branches of the skb_tailroom
> condition, before freeing the original skb, and free the copy on error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
