From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [patch] networking ipv4: remove total socket usage count from /proc/net/sockstat
Date: Mon, 16 Jan 2006 21:35:28 +0100
Message-ID: <9a8748490601161235k2defec82sa51a17e4fc14b22f@mail.gmail.com>
References: <20060116200432.GB14060@gospo.rdu.redhat.com>
	 <1137442446.19444.20.camel@mindpipe>
	 <bdfc5d6e0601161225h53554b1ahde794af93af52bdf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Lee Revell <rlrevell@joe-job.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751039AbWAPUfc@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <bdfc5d6e0601161225h53554b1ahde794af93af52bdf@mail.gmail.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/06, Andy Gospodarek <andy@greyhouse.net> wrote:
> What userspace app will break because of this?
>
> On 1/16/06, Lee Revell <rlrevell@joe-job.com> wrote:
> > On Mon, 2006-01-16 at 15:04 -0500, Andy Gospodarek wrote:
> > > Printing the total number of sockets used in /proc/net/sockstat is out
> > > of place in a file that is supposed to contain information related to
> > > ipv4 sockets.  Removed output for total socket usage.
> > >
> >
> > Um, you can't do that, it will break userspace.
> >

That's not the point. The point is you can't go around changing things
exported to usersace - that has the potential to break apps.  Even if
no app is known to the people on this list there may still be apps out
there depending on it - and we don't break userspace without *very*
good reasons, and even then it's announced for several months (years
sometimes) in Documentation/feature-removal.txt and elsewhere.

--
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
