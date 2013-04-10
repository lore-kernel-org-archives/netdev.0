From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 15:31:58 +0200
Message-ID: <2486784.Xp59DXZuXx@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1365548547.23372.2.camel@dcbw.foobar.com> <87li8q5xgi.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, Ming Lei <tom.leiming@gmail.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42218 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934947Ab3DJNbN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:31:13 -0400
In-Reply-To: <87li8q5xgi.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 April 2013 15:25:49 Bj=F8rn Mork wrote:
> Dan Williams <dcbw@redhat.com> writes:
>=20
> > +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> > +{
> > +	/* Only drivers that implement a status hook should call this */
> > +	BUG_ON(dev->interrupt =3D=3D NULL);
> >=20
> I still don't think there is any reason to BUG out. See for example
> http://article.gmane.org/gmane.linux.kernel/52102

On second consideration, yes, WARN_ON() would do the job.

	Regards
		Oliver
