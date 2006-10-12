From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bridge: flush forwarding table when device
	carrier off
Date: Thu, 12 Oct 2006 14:32:55 -0700
Message-ID: <20061012143255.556844d4@freekitty>
References: <20061012112431.0550b252@dxpl.pdx.osdl.net>
	<20061012201043.GA29253@gospo.rdu.redhat.com>
	<1160688633.5047.5.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@osdl.org,
   "David S. Miller" <davem@davemloft.net>
Return-path: <bridge-bounces@lists.osdl.org>
To: hadi@cyberus.ca
In-Reply-To: <1160688633.5047.5.camel@jzny2>
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

On Thu, 12 Oct 2006 17:30:33 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2006-12-10 at 16:10 -0400, Andy Gospodarek wrote:
> > On Thu, Oct 12, 2006 at 11:24:31AM -0700, Stephen Hemminger wrote:
> > > Flush the forwarding table when carrier is lost. This helps for
> > > availability because we don't want to forward to a downed device and
> > > new packets may come in on other links.
> > > =

> > > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> > > =

> > =

> > Stephen,
> > =

> > This is an excellent idea =

> =

> I am on the other extreme - this is problematic if you have a large
> table already learnt. Agrevate that with an unstable link and it gets a
> lot worse. Both of which dont sound unrealistic in say a wireless AP.

We don't support bridging wireless, that requires some NDS stuff that
isn't supported, and requires more softmac than the stack has.

> A more sane policy i have seen is a timer that flushes the table after a
> programmed period; this way you counter a flipflop-ing link.

That's already there.

> IOW, the best place is to have this in some user space daemon. If it has
> to be in the kernel, can you add a systcl to disable it?
> =


When RSTP is in userspace, it will do the flushing.

-- =

Stephen Hemminger <shemminger@osdl.org>
