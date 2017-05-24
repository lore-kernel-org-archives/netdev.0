From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: support cross-chip ageing time
Date: Wed, 24 May 2017 16:28:28 -0400 (EDT)
Message-ID: <20170524.162828.2304525828467660236.davem@davemloft.net>
References: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523192059.1720-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 23 May 2017 15:20:59 -0400

> Now that the switchdev bridge ageing time attribute is propagated to all
> switch chips of the fabric, each switch can check if the requested value
> is valid and program itself, so that the whole fabric shares a common
> ageing time setting.
> 
> This is especially needed for switch chips in between others, containing
> no bridge port members but evidently used in the data path.
> 
> To achieve that, remove the condition which skips the other switches. We
> also don't need to identify the target switch anymore, thus remove the
> sw_index member of the dsa_notifier_ageing_time_info notifier structure.
> 
> On ZII Dev Rev B (with two 88E6352 and one 88E6185) and ZII Dev Rev C
> (with two 88E6390X), we have the following hardware configuration:
 ...
> Before this patch:
 ...
> After this patch:
 ...
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
