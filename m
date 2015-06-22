From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: ax88179_178a: ethernet to usb dongle disconnect crash
Date: Mon, 22 Jun 2015 08:31:02 -0700
Message-ID: <20150622153102.GA15570@kroah.com>
References: <CA+vmRF6c=fnFzTraqjk0yg59iMe8T6oFNayvGgZcADja8XPWwA@mail.gmail.com>
 <20150617125341.GB15116@kroah.com>
 <CA+vmRF5n=CNDErC9PRHcCxT0O=Re9my+o1VHP6JbMS8qZ5LW5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Vivek Bhagat <vivek.bhagat89@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:54488 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbbFVPbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 11:31:03 -0400
Content-Disposition: inline
In-Reply-To: <CA+vmRF5n=CNDErC9PRHcCxT0O=Re9my+o1VHP6JbMS8qZ5LW5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 22, 2015 at 04:09:05PM +0530, Vivek Bhagat wrote:
> Hello Greg,
>=20
> Please find comments inline below-
>=20
> On Jun 17, 2015 6:23 PM, "Greg KH" <gregkh@linuxfoundation.org> wrote=
:
> >
> > On Wed, Jun 17, 2015 at 10:31:40AM +0530, Vivek Bhagat wrote:
> > > Hi All,
> > >
> > > I have connected my pc and TV board as below -
> > >
> > > PC (network i/f) <----> ethernet to usb dongle <---> usb port of =
TV board
> > >
> > > When I power off=A0 my board, i get a kernel crash.
> > > Please have a look at log attached here.I debug and found that
> > > unregister_netdev() in usbnet_disconnect() clears net_device obje=
ct
> > > and still skb is under processing which tries to access net_devic=
e
> > > object and leads to crash.
>=20
> > 3.10 is really old, please try something more "modern" like 4.0 at =
the
> > very least to see if the issue is still there.
> >
> Our linux 3.10 is having all patches included from stable version 4.0=
=2E

I doubt that.  Otherwise it would just be 4.0 :)

> Due to integration issue i can not replace vanilla 4.0 kernel in my s=
etup.

Then you are stuck getting support from the company that is forcing you
to stick with that kernel version, sorry but the community can not help
you out here.

best of luck,

greg k-h
