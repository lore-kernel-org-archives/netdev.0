From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: rename switch operations structure
Date: Wed, 24 Aug 2016 14:15:39 -0700
Message-ID: <d4265fdc-1624-7c40-5779-786bdb63375d@gmail.com>
References: <20160823163856.21456-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160823163856.21456-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2016 09:38 AM, Vivien Didelot wrote:
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
> 
>     CHECK: Comparison to NULL could be written "!ops"
>     #403: FILE: net/dsa/dsa.c:470:
>     +	if (ops == NULL) {
> 
>     CHECK: Comparison to NULL could be written "ds->ops->get_strings"
>     #773: FILE: net/dsa/slave.c:697:
>     +		if (ds->ops->get_strings != NULL)
> 
>     CHECK: Comparison to NULL could be written "ds->ops->get_ethtool_stats"
>     #824: FILE: net/dsa/slave.c:785:
>     +	if (ds->ops->get_ethtool_stats != NULL)
> 
>     CHECK: Comparison to NULL could be written "ds->ops->get_sset_count"
>     #835: FILE: net/dsa/slave.c:798:
>     +		if (ds->ops->get_sset_count != NULL)
> 
>     total: 0 errors, 0 warnings, 4 checks, 784 lines checked
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
-- 
Florian
