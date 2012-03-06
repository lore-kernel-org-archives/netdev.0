From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH net-next/usb-next v3 0/5] cdc-wdm/qmi_wwan: subdriver
 support
Date: Tue, 6 Mar 2012 06:35:59 -0800
Message-ID: <20120306143559.GB23314@kroah.com>
References: <1330528507-16551-1-git-send-email-bjorn@mork.no>
 <878vjeuebk.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60100 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030750Ab2CFOpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:45:42 -0500
Received: from compute1.internal (compute1.nyi.mail.srv.osa [10.202.2.41])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id B4E47210F5
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 09:45:41 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <878vjeuebk.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 06, 2012 at 01:03:11PM +0100, Bj=F8rn Mork wrote:
> Bj=F8rn Mork <bjorn@mork.no> writes:
>=20
> > Note that the netdev patches still depend on the 3 first patches of=
 this
> > set, and should not be applied independently. The 3 first do not ye=
t
> > apply to net-next, as they depend on other patches in usb-next and
> > linux-next. Please let me know if this sort of cross-system
> > patch set should be handled otherwise.
> >
> > All 5 patches are verified to apply cleanly to linux-next tag next-=
20120229.
> > Patches 1-3 are verified to apply to usb-next commit aac1fc386
> > Patches 4-5 are verified to apply to net-next commit 9100eb012 , bu=
t will
> > cause build errors there due to the lack of the required 3 first pa=
tches
> > as noted above.
> >
> > Bj=F8rn Mork (5):
> >   usb: cdc-wdm: split out reusable parts of probe
> >   usb: cdc-wdm: adding list lookup indirection
> >   usb: cdc-wdm: adding usb_cdc_wdm_register subdriver support
> >   net: qmi_wwan: support devices having a shared QMI/wwan interface
> >   net: qmi_wwan: add Gobi and Pantech UML290 device IDs
> >
>=20
> Hello Greg,
>=20
> I believe I may have promised to ping you when these patches were
> ready.  Please apply patch 1-3 from this series to your usb-next bran=
ch
> (for Linux 3.4). They were acked by Oliver a week ago.

Great, can you resend them to me please, with Oliver's ack?  I don't se=
e
them in my to-apply queue anymore as I thought they were still under
review.

> Patches 4 and 5 (for netdev) will have to wait until the first 3 are
> merged.

I can take them through my tree if they are dependant on the first 3,
that's not a problem.

thanks,

greg k-h
