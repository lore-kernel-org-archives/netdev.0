From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: net: nfc: BUG and panic in accept() on 3.5-rc2
Date: Mon, 25 Jun 2012 17:04:35 +0200
Message-ID: <CA+1xoqcwr-5dzHvqkt9x0-xj9EFAywVfva=asbHXvX-LSBWqdA@mail.gmail.com>
References: <1339423241.4999.53.camel@lappy> <20120611144134.GX22557@sortiz-mobl>
 <1339425693.6001.2268.camel@edumazet-glaptop> <20120611145700.GY22557@sortiz-mobl>
 <1339426778.6001.2312.camel@edumazet-glaptop> <20120611152007.GZ22557@sortiz-mobl>
 <1339433810.4999.65.camel@lappy> <20120611172545.GA1776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Dave Jones <davej@redhat.com>,
	Sasha Levin <levinsasha928@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611172545.GA1776@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 11, 2012 at 7:25 PM, Dave Jones <davej@redhat.com> wrote:
> On Mon, Jun 11, 2012 at 06:56:50PM +0200, Sasha Levin wrote:
>
> =A0> > > > > > What's trinity ?
> =A0> > > > > > Also, if this one is reproducible, would you mind shar=
ing some details about
> =A0> > > > > > how we could reproduce it ?
> =A0> > > > >
> =A0> > > > > Well, bugfix should be trivial enough ;)
> =A0> > > > Yep, I looked at the code only after looking at Sasha's re=
port.
> =A0> > > >
> =A0> > > > Thanks for the patch, do you mind if I add your SOB to it =
?
> =A0> > >
> =A0> > > I =A0would prefer making sure it fixes the bug first ;)
> =A0> > Sure, although your patch makes sense regardless of that :)
> =A0> > I'll still wait for Sasha to confirm that it fixes his crash.
> =A0>
> =A0> I don't have a direct way of reproducing it, but I've put it in =
the test
> =A0> vm and the fuzzer is running, I'll let you know tomorrow if it h=
appened
> =A0> again.
>
> You might be able to trigger it faster by using -P PF_NFC, which will
> force trinity to only use NFC sockets.
>
> sidenote: most protocols trigger the module to be auto-loaded when a =
socket
> is created. This doesn't seem to happen with nfc, making me need to m=
anually
> modprobe it first. Intentional ?

It fixes the bug, wasn't been able to reproduce it since then.
