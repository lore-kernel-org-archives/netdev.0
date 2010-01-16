From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ax25: netrom: rose: Fix timer oopses
Date: Sat, 16 Jan 2010 01:04:35 -0800 (PST)
Message-ID: <20100116.010435.55169828.davem@davemloft.net>
References: <4B2E6729.1090102@free.fr>
	<4B507FAA.8010007@free.fr>
	<20100115203654.GA3084@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpidoux@free.fr, bernard.pidoux@upmc.fr,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org, linux-hams@vger.kernel.org, rjw@sisk.pl
To: jarkao2@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20100115203654.GA3084@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 15 Jan 2010 21:36:54 +0100

> Wrong ax25_cb refcounting in ax25_send_frame() and by its callers can
> cause timer oopses (first reported with 2.6.29.6 kernel).
> 
> Fixes: http://bugzilla.kernel.org/show_bug.cgi?id=14905
> 
> Reported-by: Bernard Pidoux <bpidoux@free.fr>
> Tested-by: Bernard Pidoux <bpidoux@free.fr>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks everyone.
