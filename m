From: Mike Galbraith <efault@gmx.de>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Tue, 28 Oct 2008 15:00:33 +0100
Message-ID: <1225202433.4899.11.camel@marge.simson.net>
References: <20081027113306.5b1d5898@lxorguk.ukuu.org.uk>
	 <20081027183312.GD11494@elte.hu> <20081027193933.GB2590@ioremap.net>
	 <20081027.124848.163119274.davem@davemloft.net>
	 <1225189462.4903.238.camel@marge.simson.net>
	 <20081028103741.GA22319@elte.hu>
	 <1225191456.4903.254.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, zbr@ioremap.net,
	alan@lxorguk.ukuu.org.uk, jkosina@suse.cz,
	akpm@linux-foundation.org, a.p.zijlstra@chello.nl, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:47258 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752768AbYJ1OAk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 10:00:40 -0400
In-Reply-To: <1225191456.4903.254.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 11:57 +0100, Mike Galbraith wrote:

> I don't know where it lives.  I'm still looking, and the numbers are
> still playing games with my head.

Hm.  _Maybe_ someone needs to take a look at c7aceab.  I took it to a 26
test tree yesterday, and it lowered my throughput, though I didn't
repeat a lot, was too busy.  I just backed it out of one of my 27 test
trees, and the netperf number is 1.030, tbench is 1.040.  I'll test this
in virgin source later, but thought I should drop a note, so perhaps
someone interested in this thread can confirm/deny loss.

	-Mike

