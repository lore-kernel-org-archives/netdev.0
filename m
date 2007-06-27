From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Wed, 27 Jun 2007 12:17:42 +0200
Message-ID: <20070627101742.GB1899@ff.dom.local>
References: <JK8YO7$ED15496EC345D64436196D8FF32F355E@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756599AbXF0KJr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <JK8YO7$ED15496EC345D64436196D8FF32F355E@xandmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2007 at 04:24:07PM +0200, Jean-Baptiste Vignaud wrote:
> Hello, i have a very similar problem with 2.6.21 also;
>=20
> 2 3com NICs and they are failling randomly.
>=20
> The kernel is a basic fedora 7 kernel (2.6.21-1.3228.fc7)
> I found a bug report and added details here : https://bugzilla.redhat=
=2Ecom/bugzilla/show_bug.cgi?id=3D243960
>=20
> I'm not subcribed on this list, so please cc me if there is any quest=
ions.
>=20
> JB
>=20
> > On Tue, Jun 26, 2007 at 08:10:17AM +0200, Marcin =A6lusarz wrote:
> > ...
> > > I reproduced it on minimal config:
=2E..
> > We know your hardware should be OK - since it was fine with 2.6.20.
=2E..

It looks like there is something common in the air...

Marcin: ne2k_pci with 8390, Jean: 3com, and now I see
similar problem with 8139cp too (plus some ideas):

http://marc.info/?l=3Dlinux-netdev&m=3D118293314109648&w=3D2

So, you probably should wait a little & look for new patches here.

Cheers,
Jarek P.
