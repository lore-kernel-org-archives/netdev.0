From: David Miller <davem@davemloft.net>
Subject: Re: sky2: in free_buffers() do proper checks before call of
 rx_clean()
Date: Fri, 13 Apr 2012 12:59:54 -0400 (EDT)
Message-ID: <20120413.125954.1123124134206162716.davem@davemloft.net>
References: <20120403001327.GB10227@Neptun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mlindner@marvell.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120403001327.GB10227@Neptun>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Tue, 3 Apr 2012 02:13:27 +0200

> In sky2_open() free_buffers() is called in case that alloc_buffers() failed.
> Here we do the check for sky2->rx_le too late, since we already called
> rx_clean() which accessed rx_le. Furthermore we lack a check for sky2->rx_ring
> which is also accessed by rx_clean().
> 
> With this patch both sky2->rx_le and sky2->rx_ring are checked before
> alloc_buffers() is called.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Stephen, I'm still waiting on your review of this patch.

Thanks.
