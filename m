From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/3] constify dsa_switch_ops
Date: Wed, 23 Aug 2017 14:45:56 +0200
Message-ID: <20170823124556.GC28612@lunn.ch>
References: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1503483419-21780-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 23, 2017 at 03:46:56PM +0530, Arvind Yadav wrote:
> dsa_switch_ops are not supposed to change at runtime. All functions
> working with dsa_switch_ops provided by <net/dsa.h> work with
> const dsa_switch_ops. So mark the non-const structs as const.
> 
> Arvind Yadav (3):
>   [PATCH 1/3] net: dsa: loop: constify dsa_switch_ops
>   [PATCH 2/3] net: dsa: lan9303: constify dsa_switch_ops
>   [PATCH 3/3] net: dsa: mt7530: constify dsa_switch_ops

For the whole series:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
