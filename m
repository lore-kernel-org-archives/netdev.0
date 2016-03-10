From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: avoid writing the same
 mode
Date: Thu, 10 Mar 2016 16:11:40 -0500 (EST)
Message-ID: <20160310.161140.107358571264526650.davem@davemloft.net>
References: <1457393092-22826-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457393092-22826-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  7 Mar 2016 18:24:52 -0500

> There is no need to change the 802.1Q port mode for the same value.
> Thus avoid such message:
> 
>     [  401.954836] dsa dsa@0 lan0: 802.1Q Mode: Disabled (was Disabled)
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
