From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: rename switch operations structure
Date: Wed, 24 Aug 2016 21:46:19 -0700 (PDT)
Message-ID: <20160824.214619.11270068071703682.davem@davemloft.net>
References: <20160823163856.21456-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823163856.21456-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 23 Aug 2016 12:38:56 -0400

> Now that the dsa_switch_driver structure contains only function pointers
> as it is supposed to, rename it to the more appropriate dsa_switch_ops,
> uniformly to any other operations structure in the kernel.
> 
> No functional changes here, basically just the result of something like:
> s/dsa_switch_driver *drv/dsa_switch_ops *ops/g
> 
> However keep the {un,}register_switch_driver functions and their
> dsa_switch_drivers list as is, since they represent the -- likely to be
> deprecated soon -- legacy DSA registration framework.
> 
> In the meantime, also fix the following checks from checkpatch.pl to
> make it happy with this patch:
 ...
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
