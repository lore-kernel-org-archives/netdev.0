From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] 8139cp dev->tx_timeout
Date: Wed, 27 Jun 2007 12:43:55 +0200
Message-ID: <20070627104355.GB3438@ff.dom.local>
References: <46822182.5070002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mika.Lansirinne@stonesoft.com, netdev@vger.kernel.org,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	shemminger <shemminger@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:56702 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754011AbXF0Kfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 06:35:45 -0400
Content-Disposition: inline
In-Reply-To: <46822182.5070002@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(second try! sorry)

On 27-06-2007 10:36, Jeff Garzik wrote:
> Mika.Lansirinne@stonesoft.com wrote:
>> Hello All,
>>
>> We have been experimenting a couple of interface hangs with the 8139=
cp
>> driver. It appears that the tx buffer stops transmitting and never s=
tarts
>> up again in some yet unknown conditions. To be able to circumvent th=
is we
>> implemented the missing dev->tx_timeout function which should reset =
the
>> interface and allow it work again.
>>
>> The problem reoccurs quite seldom and we have yet to be able to conf=
irm
>> that the attached patch helps the situation. We though that we shoul=
d
>> submit the patch anyway for reviewing.
>>
>> The patch is made against 2.6.21.5 kernel.
>=20
> Seems OK, but I'm definitely interested in hearing test feedback.

Hi!

I think maybe there are too many similar problems under 2.6.21
to be individual, and there could be something common to fix?

So, I "link" here a few  probably interested souls to cc:

Subject: Re: 2.6.20->2.6.21 - networking dies after random time
=2E..
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
