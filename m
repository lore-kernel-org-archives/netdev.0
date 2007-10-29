From: Romano Giannetti <romanol@upcomillas.es>
Subject: Re: [PATCH] r8169: don't call napi_disable if not doing NAPI
Date: Mon, 29 Oct 2007 09:56:42 +0100
Message-ID: <1193648202.15743.1.camel@localhost>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org>
	 <1193232344.32208.0.camel@localhost> <20071024142759.GA13657@elte.hu>
	 <1193241191.14314.8.camel@localhost> <20071024155521.GA16690@elte.hu>
	 <1193242267.6914.6.camel@twins> <1193378269.17910.4.camel@localhost>
	 <20071026063733.GA12426@elte.hu>
	 <20071026094833.539a69aa@freepuppy.rosehill>
	 <20071026175613.GA18770@elte.hu>
	 <20071026113305.57dea765@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jeff@garzik.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ic0245.upco.es ([130.206.70.245]:42485 "EHLO
	antispam.upcomillas.es" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbXJ2I4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 04:56:45 -0400
In-Reply-To: <20071026113305.57dea765@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-10-26 at 11:33 -0700, Stephen Hemminger wrote:
> Don't call napi_disable if not configured.
> And make sure that any misuse of napi_xxx in future fails
> with a compile error.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>=20

This fix the problem for me (at least, after 8 suspend/resume cycles).=20
Thanks.

Tested-by: Romano Giannetti <romano.giannetti@gmail.com>

--=20
Sorry for the disclaimer --- =C2=A1I cannot stop it!



--
La presente comunicaci=C3=B3n tiene car=C3=A1cter confidencial y es par=
a el exclusivo uso del destinatario indicado en la misma. Si Ud. no es =
el destinatario indicado, le informamos que cualquier forma de distribu=
ci=C3=B3n, reproducci=C3=B3n o uso de esta comunicaci=C3=B3n y/o de la =
informaci=C3=B3n contenida en la misma est=C3=A1n estrictamente prohibi=
dos por la ley. Si Ud. ha recibido esta comunicaci=C3=B3n por error, po=
r favor, notif=C3=ADquelo inmediatamente al remitente contestando a est=
e mensaje y proceda a continuaci=C3=B3n a destruirlo. Gracias por su co=
laboraci=C3=B3n.

This communication contains confidential information. It is for the exc=
lusive use of the intended addressee. If you are not the intended addre=
ssee, please note that any form of distribution, copying or use of this=
 communication or the information in it is strictly prohibited by law. =
If you have received this communication in error, please immediately no=
tify the sender by reply e-mail and destroy this message. Thank you for=
 your cooperation.=20
