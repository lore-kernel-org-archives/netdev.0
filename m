From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 11:53:45 +0000
Message-ID: <1454414025.28781.146.camel@citrix.com>
References: <1454412668-6472-1-git-send-email-paul.durrant@citrix.com>
	 <20160202114646.GF10990@citrix.com>
	 <9d2b78b8dac54e6ea3f9889fd2a9db83@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
To: Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54852 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbcBBLxr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 06:53:47 -0500
In-Reply-To: <9d2b78b8dac54e6ea3f9889fd2a9db83@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-02 at 11:48 +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: Wei Liu [mailto:wei.liu2@citrix.com]
> > Sent: 02 February 2016 11:47
> > To: Paul Durrant
> > Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Ian
> > Campbell;
> > Wei Liu
> > Subject: Re: [PATCH net-next v2] xen-netback: implement dynamic
> > multicast
> > control
> >=20
> > On Tue, Feb 02, 2016 at 11:31:08AM +0000, Paul Durrant wrote:
> > [...]
> > > +static int xen_register_mcast_ctrl_watch(struct xenbus_device *d=
ev,
> > > +					=C2=A0struct xenvif *vif)
> > > +{
> > > +	int err =3D 0;
> > > +	char *node;
> > > +	unsigned maxlen =3D strlen(dev->otherend) +
> > > +		sizeof("/request-multicast-control");
> > > +
> > > +	if (vif->mcast_ctrl_watch.node)
> > > +		return -EADDRINUSE;
> > > +
> >=20
> > Sorry if I didn't make myself clear enough. I think EADDRINUSE shou=
ld
> > also be logged.
> >=20
>=20
> Ok. Not sure how much noise that will cause though.

If this is a guest trigerable path then don't forget to use the
ratelimiting printk options....

Ian.
