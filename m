From: Andrius Kasparavicius <andrius@andrius.org>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Wed, 9 Jul 2003 22:12:23 +0300 (GMT-3)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307092207550.12613-100000@hl.kauneta.net>
References: <3F0C4DBD.8020007@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3F0C4DBD.8020007@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


is there a clear list of which cards "works without patch", which
"need patches/mtu changes" and which "never seen working"?

Andrius

On Wed, 9 Jul 2003, Ben Greear wrote:

> Andrius Kasparavicius wrote:
> > hello, as far as i know, currently there is no native vlan support in
> > network device drivers. I mean, always need patching MTU.. add 4 bytes..
> > :-(
> >
> > is there any problems to include full vlans support?
>
> Intel's e100 driver (and all NICs supported by it) support vlans
> fine, as do most of the GigE NICs.  Tulip does not, last I hear, though
> a work-around patch has been around forever.  Realtek worked at one time,
> not sure about now though...
