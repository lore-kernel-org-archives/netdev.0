From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/fman: fix error handling
Date: Mon, 04 Jul 2016 17:18:43 -0700 (PDT)
Message-ID: <20160704.171843.736302345142812330.davem@davemloft.net>
References: <1467611202-15168-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: igal.liberman@freescale.com, rdunlap@infradead.org,
	standby24x7@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: christophe.jaillet@wanadoo.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467611202-15168-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Mon,  4 Jul 2016 07:46:42 +0200

> This is likely that checking 'fman->fifo_offset' instead of
> 'fman->cam_offset' is expected here.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> 
> The type of 'fifo_offset' may also need to be changed.

Fix the test rather than trying to force it into the error pointer
macro.

If fifo_offset is not a pointer, then change the test to check for
whatever would be appropriate for values returned from
fman_muram_alloc().

This is a very low quality patch submission, you submitted a "fix"
which added a new build warning and made it obvious that something
else is needed as well here.  You even stated that you realized this.
