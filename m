From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been
 left enabled.
Date: Thu, 07 Apr 2016 13:21:58 -0700
Message-ID: <1460060518.1800.8.camel@perches.com>
References: <1460049545.6715.98.camel@perches.com>
	 <1460046677.6715.95.camel@perches.com>
	 <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
	 <20160407162309.21283.11482.stgit@warthog.procyon.org.uk>
	 <24286.1460048722@warthog.procyon.org.uk>
	 <981.1460058224@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <981.1460058224@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-07 at 20:43 +0100, David Howells wrote:
> Joe Perches <joe@perches.com> wrote:
> > > Joe Perches <joe@perches.com> wrote:
> > > > It might be better to remove kenter and _enter
> > > > altogether and use function tracing instead.
> > > Possibly - but not at this time.
> > Swell.
> I didn't say I wouldn't do it - it's just that I'm trying to fix othe=
r stuff
> at the moment and don't particularly want to add that to the list jus=
t now.
> kenter, _enter and co. are serving me very well.

No worries, I didn't mean to imply you wouldn't.
It's your code, do what and when you want.

> > > Besides, isn't the function tracing log lost
> > > if the machine crashes?
> > I believe yes, but would it matter?
> Let's see...=A0=A0If the machine panics whilst I'm developing stuff (=
quite likely
> if something goes wrong in BH context), how do I get at the function =
tracing
> log to find out why it panicked if the log is then lost?=A0=A0With th=
e serial
> console, at least I automatically capture the output of kenter and co=
=2E.

But you also don't get a bunch of other useful stuff.

btw: there is ftrace_dump_on_oops

https://lwn.net/Articles/366796/
