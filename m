From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH net-next v2 6/6] r8152: support RTL8153
Date: Wed, 8 Jan 2014 18:24:17 +0000
Message-ID: <1389205457.1644.13.camel@bwh-desktop.uk.level5networks.com>
References: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
	<1388633110-1435-1-git-send-email-hayeswang@realtek.com>
	<877gai8nqu.fsf@nemi.mork.no>
	<605671F106F540BA9665A195CACB78A0@realtek.com.tw>
	<8738l58pyd.fsf@nemi.mork.no>
	<AA7EB9EA13B74B14BBE08C4278F7948C@realtek.com.tw>
	 <87eh4l31or.fsf@nemi.mork.no>
	 <749DBDC9792E47BBA5884BEC7CF2D639@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?=27Bj=F8rn?= Mork' <bjorn-yOkvZcmFvRU@public.gmane.org>,
	<oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	'nic_swsd' <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: hayeswang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <749DBDC9792E47BBA5884BEC7CF2D639-Rasf1IRRPZGoECsaD+WFmw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-01-07 at 20:35 +0800, hayeswang wrote:
>  Bj=C3=B8rn Mork [mailto:bjorn-yOkvZcmFvRU@public.gmane.org]=20
> > Sent: Monday, January 06, 2014 5:22 PM
> > To: Hayeswang
> > Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; nic_swsd;=20
> > linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: Re: [PATCH net-next v2 6/6] r8152: support RTL8153
> [...]
> > Exactly the same device, but now cfg #1 is active and a=20
> > different set of
> > drivers have bound to the interfaces.  This is possible=20
> > because none of
> > the involved drivers disable the support for this device at=20
> > build-time.
> > Instead they use the available interface descriptors for matching a=
nd
> > probing supported functions.
> >=20
> > End users will of course normally not go around writing stuff to sy=
sfs
> > attributes like this.  Creating an udev rule to select a specific
> > counfiguration when the device is plugged is more useful for normal
> > usage.
>=20
> Thanks for your answer. I would study udev rule first.
> Does the udev alwayes exist for all Linux system, such as
> Android, embedded system, and so on?

They may not have udev, but if not they will normally have an alternate
such as mdev.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
