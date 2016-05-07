From: David Miller <davem@davemloft.net>
Subject: Re: [patch] netxen: netxen_rom_fast_read() doesn't return -1
Date: Sat, 07 May 2016 15:16:21 -0400 (EDT)
Message-ID: <20160507.151621.585688267278016986.davem@davemloft.net>
References: <20160505132019.GD3038@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160505132019.GD3038@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 May 2016 16:20:20 +0300

> The error handling is broken here.  netxen_rom_fast_read() returns zero
> on success and -EIO on error.  It never returns -1.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
