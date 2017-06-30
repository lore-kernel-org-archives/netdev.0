From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH RFC 25/26] tile: Remove spin_unlock_wait() arch-specific
 definitions
Date: Thu, 29 Jun 2017 17:24:46 -0700
Message-ID: <20170630002446.GM2393@linux.vnet.ibm.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <1498780894-8253-25-git-send-email-paulmck@linux.vnet.ibm.com>
 <CA+55aFxf=4+LEk6wSE3HPFdwSf_F0Ny9NRGXaA6daikY+TGbDg@mail.gmail.com>
 <CA+55aFyogF0gpZ+5KHabFaYDhAq0awPzpSVj9S2q9EZnoY2eXQ@mail.gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Oleg Nesterov <oleg@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Manfred Spraul <manfred@colorfullife.com>,
        Tejun Heo <tj@kernel.org>, Arnd Bergmann <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        Will Deacon <will.deacon@arm.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Alan Stern <stern@rowland.harvard.edu>,
        Andrea Parri <parri.andrea@gmail.com>,
        Chris Metcalf <cmetcalf@mellanox.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFyogF0gpZ+5KHabFaYDhAq0awPzpSVj9S2q9EZnoY2eXQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2017 at 05:10:41PM -0700, Linus Torvalds wrote:
> On Thu, Jun 29, 2017 at 5:06 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Please don't make this one commit fopr every architecture.
> >
> > Once something gets removed, it gets removed. There's no point in
> > "remove it from architecture X". If there are no more users, we're
> > done with it, and making it be 25 patches with the same commit message
> > instead of just one doesn't help anybody.
> 
> Just to clarify: I think the actual *users* are worth doing one by
> one, particularly if there are user-specific explanations of what that
> particular code wanted, and why spin_unlock_wait() doesn't really
> help.

Got it, and I did merge -only- the arch-specific definition removals
into one commit.  Should I also merge the core-code definition removals
into that same commit, or is it OK to remove the core-code definitions
with one commit and the arch-specific definitions with another.

(My guess is that you would prefer I removed -all- definitions with one
commit, including the core-kernel definitions, but at this point I figure
I should just ask.)

> And I think that you actually have those per-user insights by now,
> after looking at the long thread.

One Acked-by thus far, so some progress!

> So I'm not saying "do one patch for the whole series". One patch per
> removal of use is fine - in fact preferred.

Got it.  It allows the developers and maintainers to tell me where my
analysis is wrong, for one thing.  ;-)

> But once there are no actual more users, just remove all the
> architecture definitions in one go, because explaining the same thing
> several times doesn't actually help anything.
> 
> In fact, *if* we end up ever resurrecting that thing, it's good if we
> can resurrect it in one go. Then we can resurrect the one or two users
> that turned out to matter after all and could come up with why some
> particular ordering was ok too.

Understood!

							Thanx, Paul
