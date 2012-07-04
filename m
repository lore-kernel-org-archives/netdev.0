From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: Using interface number probing for usbnet drivers before 3.6-rc1?
Date: Wed, 4 Jul 2012 08:11:05 -0700
Message-ID: <20120704151105.GA23580@kroah.com>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
 <20120622.171735.637204872051168180.davem@davemloft.net>
 <87y5neidk1.fsf@nemi.mork.no>
 <20120623.023749.1066357959466872561.davem@davemloft.net>
 <87mx3flqns.fsf_-_@nemi.mork.no>
 <20120704144649.GC23020@kroah.com>
 <87ipe3lgvm.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ipe3lgvm.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2012 at 04:50:53PM +0200, Bj=F8rn Mork wrote:
> Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org> writes:
> > On Wed, Jul 04, 2012 at 01:19:35PM +0200, Bj=F8rn Mork wrote:
> >> David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> writes:
> >> > From: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> >> > Date: Sat, 23 Jun 2012 11:26:54 +0200
> >> >
> >> >> Is waiting for 3.6-rc1 the best alternative, or is cherry-picki=
ng them
> >> >> an option?
> >> >
> >> > I'm extremely reluctant to have a dependency on another tree.
> >> >
> >> > The USB tree, on the other hand, could pull the net-next tree
> >> > in so you can continue your dependent work there.
> >>=20
> >> Hello Greg,
> >>=20
> >> I know I said I would be more careful about cross-tree dependencie=
s, but
> >> here I am again...
> >>=20
> >> The context is: How should I proceed with interface number based p=
robing
> >> for usbnet drivers, in particular qmi_wwan which already has a few
> >> patches in net-next?
> >>=20
> >> I see two possible remaining options:
> >>=20
> >>  1) you pull the net-next changes into usb-next so that I can do t=
he
> >>     work against usb-next now, or
> >>  2) I wait for 3.6-rc1 and do the work against the net tree after
> >>     3.6-rc1 is merged there
> >>=20
> >> I have decided to go for option #2 unless either of you have other
> >> preferences, as I believe that is going to cause the least work an=
d
> >> merge trouble for you both.
> >
> > What about:
> >    3) You send the usb interface number matching patches again for =
them
> >    to be included in the net-next tree as well, causing duplicates =
to be
> >    in linux-next, but allowing you to send your patches into net-ne=
xt.
> >
> > That is what we have done at times for other patches, and if David =
is ok
> > with it, so am I.  Odds are, the merge will happen automatically, b=
ut if
> > not, I can handle it when 3.6-rc1 comes around.
> >
> > Sound good?
>=20
> I could have misunderstood, but I thought that was out of the questio=
n
> given that David didn't want to cherry-pick them from usb-next.

Well, I said to email them again, which makes it easier for David, but
if he doesn't want to do that, then you will have to wait for option 2
above, sorry.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
