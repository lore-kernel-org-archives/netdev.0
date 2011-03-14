From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 14 Mar 2011 10:56:12 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1103141053020.2787@localhost6.localdomain6>
References: <20110314152456.b49b2693.sfr@canb.auug.org.au> <1300078778.3962.22.camel@localhost> <20110314163135.f366742e.sfr@canb.auug.org.au> <20110313.225312.193696949.davem@davemloft.net> <20110314170546.af552b4e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110314170546.af552b4e.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2011, Stephen Rothwell wrote:

> Hi Dave,
> 
> On Sun, 13 Mar 2011 22:53:12 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> >
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 14 Mar 2011 16:31:35 +1100
> > 
> > > Maybe some config option changed ...
> > 
> > Perhaps GENERIC_HARDIRQS_NO_DEPRECATED?
> 
> Yep, that has been turned on for powerpc now.  I guess you will have the
> same problem on sparc64 of you merge the net-next and sparc trees ...

Yeah, powerpc alone compiles with GENERIC_HARDIRQS_NO_DEPRECATED as it
does not have that notify commit.

If you add net which has that notify commit, but not the fix it
breaks. I wonder whether Dave should pick that fix into net.

Thanks,

	tglx
