From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.12-rcx networking oops
Date: Tue, 7 Jun 2005 08:34:51 -0700
Message-ID: <20050607153451.GA28776@linuxace.com>
References: <20050531224012.GA16789@linuxace.com> <20050601054955.GA2625@gondor.apana.org.au> <20050601170058.GA20112@linuxace.com> <20050606224646.24af30ff.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: randy_dunlap <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20050606224646.24af30ff.rdunlap@xenotime.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 10:46:46PM -0700, randy_dunlap wrote:
> Agreed, the stack trace is suspicious.  (more below)

Yes, many of the oops i've collected are questionable...

> This is with NAPI, right?  Would it make sense to try it with that
> disabled?  (I don't recall you saying it's NAPI, but the e1000
> functions seem to indicate that.)

It is NAPI, but it works fine up to 2.6.11-rc1.  2.6.11-rc2 fails,
so I'm now testing each individual -bk snapshot between them in 
hopes of finding the offending changeset.  Given that this box
is a firewall, it could be the slew of large netfilter changes
which went into -rc2, but we'll see.

> and how about enabling CONFIG_FRAME_POINTER ?

It is enabled.

Phil
