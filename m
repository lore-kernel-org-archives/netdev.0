From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] drivers/net/e1000/e1000_main.c: Fix message logging
	defect
Date: Fri, 11 Jun 2010 12:46:08 -0700
Message-ID: <AANLkTilHvo4aJPLiGJywWE3EvXtYO5r9BEuoqsbYX4vt@mail.gmail.com>
References: <1276237773.1556.507.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276237773.1556.507.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 10, 2010 at 23:29, Joe Perches <joe@perches.com> wrote:
> commit 675ad47375c76a7c3be4ace9554d92cd55518ced
> removed the capability to use ethtool.set_msglevel to
> control the types of messages emitted by the driver.
>
> That commit should probably be reverted.
>
> If not, then this patch fixes a message logging defect
> introduced by converting a printk without KERN_<level>
> to e_info.
>
> This also reduces text by about 200 bytes.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

Thanks Joe.  I have added the patch to my queue.
