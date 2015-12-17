From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: use-after-free in sixpack_close
Date: Thu, 17 Dec 2015 22:34:00 +0100
Message-ID: <20151217213400.GA15130@linux-mips.org>
References: <CACT4Y+YfPHHON7VywV_G-qOyQ0wv6UVB0uxFAGf1aGKpfAP-KA@mail.gmail.com>
 <20151217114104.6946d72b@lxorguk.ukuu.org.uk>
 <20151217.160532.999129498473749695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gnomes@lxorguk.ukuu.org.uk, dvyukov@google.com,
	ajk@comnets.uni-bremen.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, jslaby@suse.com,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151217.160532.999129498473749695.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 17, 2015 at 04:05:32PM -0500, David Miller wrote:

> This should fix it, the only thing I'm unsure of is if we should perhaps
> also use del_timer_sync() here.  Anyone?

I think so.

  Ralf
