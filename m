From: Mike Galbraith <efault@gmx.de>
Subject: Re: [rfc/rft][patch] should use scheduler sync hint in
 tcp_prequeue()?
Date: Tue, 02 Mar 2010 12:39:42 +0100
Message-ID: <1267529982.9365.7.camel@marge.simson.net>
References: <1267522901.25906.101.camel@marge.simson.net>
	 <1267529273.2964.111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267529273.2964.111.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-02 at 12:27 +0100, Eric Dumazet wrote:

> This wake_up_interruptible_sync_poll() change might be good for loopback
> communications (and pleases tbench), but is it desirable for regular
> multi flows NIC traffic ?

If you can take high frequency cache misses, likely yes.  For localhost,
that's pretty much guaranteed currently (ergo the question).

	-Mike
