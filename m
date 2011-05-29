From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Subject: Re: [Xen-devel] Re: [PATCH] ethtool: ETHTOOL_SFEATURES:
 remove NETIF_F_COMPAT return
Date: Sun, 29 May 2011 11:38:49 +0200
Message-ID: <20110529093849.GA5245@rere.qmqm.pl>
References: <20110524.153930.610330240390616957.davem@davemloft.net>
	<20110524215923.GA20138@rere.qmqm.pl>
	<1306505626.2759.4.camel@bwh-desktop>
	<20110527152809.GA7620@rere.qmqm.pl>
	<1306511150.2759.17.camel@bwh-desktop>
	<20110527163409.GA8497@rere.qmqm.pl>
	<1306538755.2759.31.camel@bwh-desktop>
	<20110528073525.GA19033@rere.qmqm.pl>
	<1306577228.23577.17.camel@dagon.hellion.org.uk>
	<BANLkTime8PHYe+BFELt92gg7SZ91xKvAwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	"xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org" <xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org>,
	Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	xen-api-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTime8PHYe+BFELt92gg7SZ91xKvAwA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 28, 2011 at 10:31:03AM -0700, Jesse Gross wrote:
> 2011/5/28 Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>:
> > On Sat, 2011-05-28 at 08:35 +0100, Micha=B3 Miros=B3aw wrote:
> >> On Sat, May 28, 2011 at 12:25:55AM +0100, Ben Hutchings wrote:
> >> > On Fri, 2011-05-27 at 18:34 +0200, Micha=B3 Miros=B3aw wrote:
> >> > > On Fri, May 27, 2011 at 04:45:50PM +0100, Ben Hutchings wrote:
> >> > > > On Fri, 2011-05-27 at 17:28 +0200, Micha=B3 Miros=B3aw wrote:
> >> > [...]
> >> > > > > =A0 =A0 =A0(note: ETHTOOL_S{SG,...} are not ever going away)
> >> > > > > =A0 =A0- causes NETIF_F_* to be an ABI
> >> > > > If feature flag numbers are not stable then what is the point of
> >> > > > /sys/class/net/<name>/features? =A0Also, I'm not aware that feat=
ures have
> >> > > > ever been renumbered in the past.
> >> > > Since no NETIF_F_* were exported earlier, I assume /sys/class/net/=
*/features
> >> > > is a debugging aid. What is it used for besides that?
> >> > xen-api <https://github.com/xen-org/xen-api> uses it in
> >> > scripts/InterfaceReconfigureVswitch.py. =A0Though it doesn't seem to=
 be
> >> > used for a particularly good reason...
> >> Look like it should use ETHTOOL_GFLAGS instead for netdev_has_vlan_acc=
el().
> ETHTOOL_GFLAGS didn't expose the vlan acceleration flags until 2.6.37,
> which is why /sys/class/net was used instead.

https://github.com/xen-org/xen-api/commit/78b8078e6ae3cf48179859bed6350bb32=
6987546

The commit using it was introduced after 2.6.37 kernel was released and uses
undocumented acccess path to the bits in question. What is the kernel patch
this commit is referring to?

Best Regards,
Micha=B3 Miros=B3aw
