From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net-ethtool: Allow ethtool to set interface
 in loopback mode.
Date: Tue, 29 Mar 2011 14:54:11 +0100
Message-ID: <1301406851.2703.1.camel@bwh-desktop>
References: <1301351066-24916-1-git-send-email-maheshb@google.com>
	 <1301356123.27727.41.camel@bwh-desktop>
	 <20110329133941.GA15944@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:43401 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1C2NyO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 09:54:14 -0400
In-Reply-To: <20110329133941.GA15944@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-29 at 15:39 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Mar 29, 2011 at 12:48:43AM +0100, Ben Hutchings wrote:
> > I'm sorry that things keep changing under your feet.  Unfortunately=
 I'm
> > going to have to ask for more changes; see below.
> >=20
> > I'm cc'ing Micha=C5=82 Miros=C5=82aw so he can comment on how he th=
inks the
> > generic feature handling should be extended.
> >=20
> > On Mon, 2011-03-28 at 15:24 -0700, Mahesh Bandewar wrote:
> > > Add second word for feature (currently it's single word). Also us=
e the first
> > > bit of the second word to set the loopback mode. By configuring t=
he interface
> > > in loopback mode in conjunction with a policy route / rule, a use=
r-land
> > > application can stress the egress / ingress path exposing the flo=
ws of the
> > > change in progress and potentially help developer(s) understand t=
he impact of
> > > those changes without even sending a packet out on the network.
>=20
> For one, adding more feature words should be separate patch to the on=
e
> introducing loopback mode.
>=20
> Unless I missed some patches, there's still one or two bits left in f=
eatures
> you can use. This will be a lot less work for you.
[...]

I recommended Mahesh to use a second word for this flag because it is
not something the networking stack needs to be aware of.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

