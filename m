From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/8] Intel I/O Acceleration Technology (I/OAT)
Date: Sat, 04 Mar 2006 18:08:19 -0800 (PST)
Message-ID: <20060304.180819.44228793.davem@davemloft.net>
References: <Pine.LNX.4.61.0603041945520.29991@yvahk01.tjqt.qr>
	<20060304.134144.122314124.davem@davemloft.net>
	<20060305014324.GA20026@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@linux01.gwdg.de, christopher.leech@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751860AbWCECIO@vger.kernel.org>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060305014324.GA20026@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sun, 5 Mar 2006 04:43:25 +0300

> According to investigation made for kevent based FS AIO reading,
> get_user_pages() performange graph looks like sqrt() function
> with plato starting on about 64-80 pages on Xeon 2.4Ghz with 1Gb of ram,
> while memcopy() is linear, so it can be noticebly slower than
> copy_to_user() if get_user_pages() is used aggressively, so userspace
> application must reuse the same, already grabbed buffer for maximum
> performance, but Intel folks did not provide theirs usage case and any
> benchmarks as far as I know.

Of course, and programming the DMA controller has overhead
as well.  This is why would would not use I/O AT with small
transfer sizes.
