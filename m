From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: fix uninitialized error return
Date: Thu, 28 Apr 2016 16:29:35 -0400 (EDT)
Message-ID: <20160428.162935.1502512352683455462.davem@davemloft.net>
References: <1461622282-30463-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461622282-30463-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 25 Apr 2016 23:11:22 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The error return err is not initialized and there is a possibility
> that err is not assigned causing mv88e6xxx_port_bridge_join to
> return a garbage error return status. Fix this by initializing err
> to 0.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
