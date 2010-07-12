From: James Bottomley <James.Bottomley@suse.de>
Subject: Re: [PATCH net-next] drivers/scsi: Remove warnings after vsprintf
 %pV introduction
Date: Mon, 12 Jul 2010 04:27:18 -0400
Message-ID: <1278923239.32614.1.camel@mulgrave.site>
References: <1278562423.1712.43.camel@Joe-Laptop>
	 <20100710.195210.200371025.davem@davemloft.net>
	 <1278824921.1501.37.camel@Joe-Laptop.home>
	 <20100710.231026.233698429.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de, matthew@wil.cx, linux-scsi@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100710.231026.233698429.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-07-10 at 23:10 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sat, 10 Jul 2010 22:08:41 -0700
> 
> > On Sat, 2010-07-10 at 19:52 -0700, David Miller wrote:
> >> Could you take a stab at this and the other scsi bits that
> >> trigger this warning?
> > 
> > Remove warnings introduced by conversions of dev_<level>
> > macros to functions.
> > 
> > Compile tested only.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> SCSI folks, the background is that we have moved the dev_*() printk
> macros to external functions, so that the prefixing printf strings
> don't get emitting at every call site.
> 
> As a consequence, dev_*() calls that try to use an empty string as the
> printf format emit a warning from gcc since an empty constant string
> is not a valid printf format.
> 
> That's what this change is all about.

Thanks, that explains the "" -> " " conversions.

What's the other 60% of the patch about? the strange addition of
scsi_show_extd_sense_args() and all the KERN_CONT bits?

James
