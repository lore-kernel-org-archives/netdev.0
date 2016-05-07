From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] netxen: fix error handling in
 netxen_get_flash_block()
Date: Sat, 07 May 2016 15:16:11 -0400 (EDT)
Message-ID: <20160507.151611.103826673825266201.davem@davemloft.net>
References: <20160505131846.GB3038@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@qlogic.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160505131846.GB3038@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 May 2016 16:18:46 +0300

> My static checker complained that "v" can be used unintialized if
> netxen_rom_fast_read() returns -EIO.  That function never actually
> returns -1.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
