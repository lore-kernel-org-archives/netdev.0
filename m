From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Wed, 18 Sep 2013 18:35:49 +0200
Message-ID: <20130918183549.3e7b8f4c@skate>
References: <20130915205701.5c61a444@skate>
	<20130916065047.GH27487@1wt.eu>
	<20130916175152.4e013457@skate>
	<CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com>
	<20130916163937.GC3188@1wt.eu>
	<20130916164412.GD3188@1wt.eu>
	<CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com>
	<20130916174708.GG3188@1wt.eu>
	<20130916182807.GO12758@n2100.arm.linux.org.uk>
	<CACzLR4suLD90p=sEhB-qg1u35t66zKfrGQref1jX42fEfu3D8g@mail.gmail.com>
	<20130917060111.GB9325@1wt.eu>
	<CACzLR4t2ABZdRk40VUhLtDKXX2PQiSVoQZQ4coQkNkvETnY6Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:38953 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751612Ab3IRQfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 12:35:52 -0400
In-Reply-To: <CACzLR4t2ABZdRk40VUhLtDKXX2PQiSVoQZQ4coQkNkvETnY6Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Ethan Tuttle,

On Tue, 17 Sep 2013 23:30:56 -0700, Ethan Tuttle wrote:
> On Mon, Sep 16, 2013 at 11:01 PM, Willy Tarreau <w@1wt.eu> wrote:
> > Next step should be that you test both kernels to be sure.
> 
> Thanks for the kernel images, Willy.  I'm still experimenting but
> initial results are strange: I haven't seen a crash from the -ethan
> image you provided, nor by a kernel with that config that I built
> myself.  The config is only different from my crashing config by a few
> options.  So perhaps some combination of options prevents the crash.
> I'll see if I can narrow it down.

A toolchain generating some crappy code maybe? Ethan, Willy, comparing
your toolchain (compiler version, origin of the toolchain) could be
interesting.

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
