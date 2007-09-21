From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: Please pull 'iwlwifi' branch of wireless-2.6
Date: Fri, 21 Sep 2007 09:20:30 +0800
Message-ID: <1190337630.5718.136.camel@debian.sh.intel.com>
References: <20070918185040.GF4940@tuxdriver.com>
	 <20070919101326.GA32432@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070919101326.GA32432-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-19 at 11:13 +0100, Christoph Hellwig wrote:
> it really needs to be moved into a directory of it's own.

It used to be... John?

> The useless per-file CFLAGS need to go most places can trivially
> be made unconditional anyway.

OK.

> The depends on m for CONFIG_IWL4965 and CONFIG_IWL3945 needs to go,
> we don't put drivers int that need to be modular. 

Since we splited the code base for 3945 and 4965 by a simple "fork" of
file iwl-base.c, some non-static functions names remain the same. Make
the two drivers build into vmlinux at the same time will cause conflict.
So to make them depend on m is a current workaround for .24. We will
abstract a common iwl-core.ko and make driver specific iwl3945.ko and
iwl4965.ko depend on it in .25 time frame.

Thanks,
-yi
