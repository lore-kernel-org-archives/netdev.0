From: Willy Tarreau <w@1wt.eu>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Wed, 18 Sep 2013 18:49:48 +0200
Message-ID: <20130918164948.GA18754@1wt.eu>
References: <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com> <20130916163937.GC3188@1wt.eu> <20130916164412.GD3188@1wt.eu> <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com> <20130916174708.GG3188@1wt.eu> <20130916182807.GO12758@n2100.arm.linux.org.uk> <CACzLR4suLD90p=sEhB-qg1u35t66zKfrGQref1jX42fEfu3D8g@mail.gmail.com> <20130917060111.GB9325@1wt.eu> <CACzLR4t2ABZdRk40VUhLtDKXX2PQiSVoQZQ4coQkNkvETnY6Rw@mail.gmail.com> <20130918183549.3e7b8f4c@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:40066 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055Ab3IRQuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 12:50:23 -0400
Content-Disposition: inline
In-Reply-To: <20130918183549.3e7b8f4c@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 18, 2013 at 06:35:49PM +0200, Thomas Petazzoni wrote:
> Dear Ethan Tuttle,
> 
> On Tue, 17 Sep 2013 23:30:56 -0700, Ethan Tuttle wrote:
> > On Mon, Sep 16, 2013 at 11:01 PM, Willy Tarreau <w@1wt.eu> wrote:
> > > Next step should be that you test both kernels to be sure.
> > 
> > Thanks for the kernel images, Willy.  I'm still experimenting but
> > initial results are strange: I haven't seen a crash from the -ethan
> > image you provided, nor by a kernel with that config that I built
> > myself.  The config is only different from my crashing config by a few
> > options.  So perhaps some combination of options prevents the crash.
> > I'll see if I can narrow it down.
> 
> A toolchain generating some crappy code maybe? Ethan, Willy, comparing
> your toolchain (compiler version, origin of the toolchain) could be
> interesting.

I thought about this but it looks suspicious, I don't see why the toolchain
would produce random bitflips.

My toolchain is a linaro 4.7 gcc into which I have added support for a
"pj4b" CPU target which is essentially the same as cortex-a9 plus support
for the IDIV instruction in thumb mode.

But I can send it to Ethan if that helps.

Willy
