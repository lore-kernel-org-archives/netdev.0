From: Bart Alewijnse <scarfboy@gmail.com>
Subject: Re: gigabit trouble
Date: Fri, 30 Jul 2004 17:15:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <b71082d804073008157cf1d6c0@mail.gmail.com>
References: <b71082d8040729094537e59a11@mail.gmail.com> <20040729210401.A32456@electric-eye.fr.zoreil.com> <b71082d80407291541f9d6f93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <b71082d80407291541f9d6f93@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004 00:41:03 +0200, Bart Alewijnse <scarfboy@gmail.com> wrote:
> I was going to do an exhaustive test, but because my computer stopped
> running completely, I'll reply to the one or two bits I can now.

...which was unrelated. Although I can't get the noise anymore
now either. I'm not too happy, I like my problems reproducable.
Of course, in the course of tring to fix the nonbootability, I changed
a bunch of things. Hrm.
I'll try getting it back later.

> > > So, question one - how do I see the link speed under linux, and how,
> > > if at all, do I control it?
> >
> > ethtool
> Thanks. That wasn't the problem - the line speed's a gbit.

Definately. I've now seen speeds up to 22MB/s, but only in pure
network benching (netio), and only with udp, although I guess
that makes a some sense.

(Also, for some reason it makes a respectable difference which
computer I run the netio server on. I mean, netio measures
speed both ways on one run, and it's different depending on
where I run it. I guess that suggests io limiting)

So the hanging around ten MB/s was just coincidence - it still
does it in both nfs and samba, but I guess it's io limited
*somewhere*, but trying to figure out why doesn't belong
in this list, I guess. Or maybe it does; I've always wondered
why samba hangs around 3, 4, 5, maybe 6 MB/s on a 100mbit
link - which with netio shows that it can go at 11MB/s, its full
speed - and even nfs rarely tops above eight. On my friend's
setup too, and he *does* have respectable hardware in his
server:)

I assume the 20MB/s top speed on my gbit cards is io limiting,
and possibly the fact that they're 32bit cards in 33mhz slots.
Still, it's far from impressive. Any suggestions (on where to
go) about improving it?

Anyhow, thanks for the help so far.

--Bart Alewijnse
