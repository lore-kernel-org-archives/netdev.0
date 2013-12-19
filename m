From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/hamradio: Integer overflow in
 hdlcdrv_ioctl()
Date: Thu, 19 Dec 2013 15:03:01 -0500 (EST)
Message-ID: <20131219.150301.1452969308105598247.davem@davemloft.net>
References: <1387250728-10795-1-git-send-email-fanwlexca@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.opdenacker@free-electrons.com, gaofeng@cn.fujitsu.com,
	akpm@linux-foundation.org, t.sailer@alumni.ethz.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: fanwlexca@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387250728-10795-1-git-send-email-fanwlexca@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wenliang Fan <fanwlexca@gmail.com>
Date: Tue, 17 Dec 2013 11:25:28 +0800

> The local variable 'bi' comes from userspace. If userspace passed a
> large number to 'bi.data.calibrate', there would be an integer overflow
> in the following line:
> 	s->hdlctx.calibrate = bi.data.calibrate * s->par.bitrate / 16;
> 
> Signed-off-by: Wenliang Fan <fanwlexca@gmail.com>

Applied and queued up for -stable, thanks.
