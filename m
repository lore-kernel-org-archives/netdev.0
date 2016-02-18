From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/1] ser_gigaset: use container_of() instead of detour
Date: Thu, 18 Feb 2016 23:14:59 +0100
Message-ID: <1455833699.2379.19.camel@tiscali.nl>
References: <1455827348-8574-1-git-send-email-pebolle@tiscali.nl>
	 <1455827348-8574-2-git-send-email-pebolle@tiscali.nl>
	 <56C63AB7.9060401@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Martin Wilck <Martin.Wilck@ts.fujitsu.com>,
	Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
	linux-kernel@vger.kernel.org,
	gigaset307x-common@lists.sourceforge.net
To: Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C63AB7.9060401@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On do, 2016-02-18 at 22:42 +0100, Tilman Schmidt wrote:
> Acked-by: Tilman Schmidt <tilman@imap.cc>
> 
> Thanks for cleaning up the mess I left behind.

That's not how I look at it.

Commit 4c5e354a9742 ("ser_gigaset: fix deallocation of platform device
structure") provided a plausible fix for the issue we were trying to fix
two months ago. If the platform code hadn't been broken when you wrote
it - broken for ser_gigaset's corner case, that is - you would have
noticed the lifetime rules of driver_data the hard way. (I suspect I
might have never noticed if syzkaller hadn't insisted in rubbing my nose
in it.)

So chances are you would have come up with something similar to this fix
would commit 25cad69f21f5 ("base/platform: Fix platform drivers with no
probe callback") already have landed.

Thanks,


Paul Bolle
