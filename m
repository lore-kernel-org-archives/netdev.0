From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_en: Fix uninitialized use of 'port_up' in
 mlx4_en_set_channels()
Date: Sun, 18 May 2014 21:14:57 -0400 (EDT)
Message-ID: <20140518.211457.1577062584301411622.davem@davemloft.net>
References: <1400363523-18371-1-git-send-email-cengelma@gmx.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	linux-kernel@vger.kernel.org
To: cengelma@gmx.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400363523-18371-1-git-send-email-cengelma@gmx.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Engelmayer <cengelma@gmx.at>
Date: Sat, 17 May 2014 23:52:03 +0200

> Function mlx4_en_set_channels() stops running ports before performing the
> requested action. In that case local variable 'port_up' is set so that the
> port is restarted at the end of the function, however, in case the port was
> not stopped, variable 'port_up' is left uninitialized and the behaviour is
> undetermined. Detected by Coverity - CID 751497.
> 
> Signed-off-by: Christian Engelmayer <cengelma@gmx.at>

Applied, thanks.
