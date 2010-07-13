From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/scsi: Remove warnings after vsprintf
 %pV introduction
Date: Mon, 12 Jul 2010 20:37:11 -0700 (PDT)
Message-ID: <20100712.203711.84385391.davem@davemloft.net>
References: <1278824921.1501.37.camel@Joe-Laptop.home>
	<20100710.231026.233698429.davem@davemloft.net>
	<1278923239.32614.1.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de, matthew@wil.cx, linux-scsi@vger.kernel.org
To: James.Bottomley@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278923239.32614.1.camel@mulgrave.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <James.Bottomley@suse.de>
Date: Mon, 12 Jul 2010 04:27:18 -0400

> What's the other 60% of the patch about? the strange addition of
> scsi_show_extd_sense_args() and all the KERN_CONT bits?

Well the new function is for logical seperation, and KERN_CONT
is what is supposed to be at the front of every printk format
that continues a partially-printed line.
