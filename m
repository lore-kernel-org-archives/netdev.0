From: Romano Giannetti <romanol@upcomillas.es>
Subject: Re: [PATCH] r8169: don't call napi_disable if not doing NAPI
Date: Sun, 28 Oct 2007 23:18:29 +0100
Message-ID: <1193609909.9177.3.camel@rukbat>
References: <alpine.LFD.0.999.0710232057080.30120@woody.linux-foundation.org>
	 <1193232344.32208.0.camel@localhost> <20071024142759.GA13657@elte.hu>
	 <1193241191.14314.8.camel@localhost> <20071024155521.GA16690@elte.hu>
	 <1193242267.6914.6.camel@twins> <1193378269.17910.4.camel@localhost>
	 <20071026063733.GA12426@elte.hu>
	 <20071026094833.539a69aa@freepuppy.rosehill>
	 <20071026175613.GA18770@elte.hu>
	 <20071026113305.57dea765@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754113AbXJ1WSr@vger.kernel.org>
In-Reply-To: <20071026113305.57dea765@freepuppy.rosehill>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-10-26 at 11:33 -0700, Stephen Hemminger wrote:
> Don't call napi_disable if not configured.
> And make sure that any misuse of napi_xxx in future fails
> with a compile error.

Will test as soon as possible (been without internet in the week end).=20
Thanks.

As a bonus, I tried more thing, and I had a signal form lockdep. You ca=
n
find it here:

http://www.dea.icai.upcomillas.es/romano/linux/info/2624rc1_5/

patching and compiling now.

Romano=20

--=20
Sorry for the disclaimer --- =A1I cannot stop it!



--
La presente comunicaci=F3n tiene car=E1cter confidencial y es para el e=
xclusivo uso del destinatario indicado en la misma. Si Ud. no es el des=
tinatario indicado, le informamos que cualquier forma de distribuci=F3n=
, reproducci=F3n o uso de esta comunicaci=F3n y/o de la informaci=F3n c=
ontenida en la misma est=E1n estrictamente prohibidos por la ley. Si Ud=
=2E ha recibido esta comunicaci=F3n por error, por favor, notif=EDquelo=
 inmediatamente al remitente contestando a este mensaje y proceda a con=
tinuaci=F3n a destruirlo. Gracias por su colaboraci=F3n.

This communication contains confidential information. It is for the exc=
lusive use of the intended addressee. If you are not the intended addre=
ssee, please note that any form of distribution, copying or use of this=
 communication or the information in it is strictly prohibited by law. =
If you have received this communication in error, please immediately no=
tify the sender by reply e-mail and destroy this message. Thank you for=
 your cooperation.=20
