From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: read then write PVID
Date: Thu, 10 Mar 2016 16:11:35 -0500 (EST)
Message-ID: <20160310.161135.1253557043734177722.davem@davemloft.net>
References: <1457393079-22740-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457393079-22740-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  7 Mar 2016 18:24:39 -0500

> The port register 0x07 contains more options than just the default VID,
> even though they are not used yet. So prefer a read then write operation
> over a direct write.
> 
> This also allows to keep track of the change through dynamic debug.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
