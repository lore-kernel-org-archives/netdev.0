From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: promote netfilter MARK value from IPv6 packets to sit
 packets
Date: Mon, 24 Feb 2003 21:30:11 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030224212312.Y44654@shell.cyberus.ca>
References: <20030217145727.GA3413@hensema.net> <20030223193339.GD15385@sunbeam.de.gnumonks.org>
 <20030223234225.GA23556@hensema.net> <20030224083946.H34066@shell.cyberus.ca>
 <20030224144116.GN24960@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Erik Hensema <erik@hensema.net>, "" <netdev@oss.sgi.com>,
   Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030224144116.GN24960@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 24 Feb 2003, Harald Welte wrote:

> On Mon, Feb 24, 2003 at 08:41:10AM -0500, jamal wrote:
> > If this is to be a config option, it should not be restricted to
> > netfilter specifics but rather skb specifics. Example the tcindex
> > (maybe even the cb) etc.
>
> No problem with me.  I do understand the usefulness of tcindex, but what
> would a totally different protcol (or the user) do with the cb of a
> different protocol?
>

cb is a maybe - it could be useful i think since the inner and outer
headers may be closely related and so share the same state.
I gacve tcindex as an example; others are: priority and some of the
other netfilter stuff (is nfcache still used?) etc.

cheers,
jamal
