From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH] once: switch to new jump label API
Date: Mon, 9 Oct 2017 13:27:08 -0700
Message-ID: <20171009202708.GB67463@gmail.com>
References: <20170821234241.88438-1-ebiggers3@gmail.com>
 <874lszmoh2.fsf@stressinduktion.org>
 <20170916040751.GA14238@zzz.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Jason Baron <jbaron@akamai.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Eric Biggers <ebiggers@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170916040751.GA14238@zzz.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 15, 2017 at 09:07:51PM -0700, Eric Biggers wrote:
> On Tue, Aug 22, 2017 at 02:44:41PM -0400, Hannes Frederic Sowa wrote:
> > Eric Biggers <ebiggers3@gmail.com> writes:
> > 
> > > From: Eric Biggers <ebiggers@google.com>
> > >
> > > Switch the DO_ONCE() macro from the deprecated jump label API to the new
> > > one.  The new one is more readable, and for DO_ONCE() it also makes the
> > > generated code more icache-friendly: now the one-time initialization
> > > code is placed out-of-line at the jump target, rather than at the inline
> > > fallthrough case.
> > >
> > > Signed-off-by: Eric Biggers <ebiggers@google.com>
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org.
> > 
> > Thanks!
> 
> Great!  Who though is the maintainer for this code?  It seems it was originally
> taken by David Miller through the networking tree.  David, are you taking
> further patches to the "once" functions, or should I be trying to get this into
> -mm, or somewhere else?
> 
> Eric

Ping.
