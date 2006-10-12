From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] bridge: flush forwarding table when device
	carrier off
Date: Thu, 12 Oct 2006 17:47:39 -0400
Message-ID: <1160689660.5047.27.camel@jzny2>
References: <20061012112431.0550b252@dxpl.pdx.osdl.net>
	<20061012201043.GA29253@gospo.rdu.redhat.com>
	<1160688633.5047.5.camel@jzny2>  <20061012143255.556844d4@freekitty>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@osdl.org,
   "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.osdl.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061012143255.556844d4@freekitty>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-10 at 14:32 -0700, Stephen Hemminger wrote:

> > I am on the other extreme - this is problematic if you have a large
> > table already learnt. Agrevate that with an unstable link and it gets a
> > lot worse. Both of which dont sound unrealistic in say a wireless AP.
> =

> We don't support bridging wireless, that requires some NDS stuff that
> isn't supported, and requires more softmac than the stack has.
> =


I was more thinking of wireless-to-ethernet bridging; that should still
work, no? i.e say eth1 on wireless with eth0 on the wired side? =

In any case, that may be a bad example (and a digression) of something
that learns large tables. I have however seen 1K entries in bridging.

> > A more sane policy i have seen is a timer that flushes the table after a
> > programmed period; this way you counter a flipflop-ing link.
> =

> That's already there.
> =


ah, ok. So the patch is in an alternative to this then? =


> > IOW, the best place is to have this in some user space daemon. If it has
> > to be in the kernel, can you add a systcl to disable it?
> > =

> =

> When RSTP is in userspace, it will do the flushing.

Cool. And that makes a lot of sense.

cheers,
jamal
