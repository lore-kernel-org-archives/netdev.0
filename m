From: Josh Boyer <jwboyer@redhat.com>
Subject: Re: 3.9 merge window kernels
Date: Mon, 25 Feb 2013 20:12:09 -0500
Message-ID: <20130226011209.GC2071@hansolo.jdub.homelinux.org>
References: <20130222234825.GB2419@hansolo.jdub.homelinux.org>
 <20130222210938.4f62cede@redhat.com>
 <512816AD.9050406@gmail.com>
 <20130222223014.1b9a2cc0@redhat.com>
 <512857FB.3050803@gmail.com>
 <20130223090148.4a4bd5e0@redhat.com>
 <CA+5PVA46LfV-WTkJVF7fz9nrz1Qrib894fqMo+8GL8AjuW8_Yg@mail.gmail.com>
 <5129491A.5020406@gmail.com>
 <512AAED8.3070205@iki.fi>
 <512BFC31.7010800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Antti Palosaari <crope@iki.fi>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	kernel@lists.fedoraproject.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Stephen Hemminger <shemminger@osdl.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932850Ab3BZBM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2013 20:12:28 -0500
Content-Disposition: inline
In-Reply-To: <512BFC31.7010800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2013 at 01:05:05AM +0100, poma wrote:
> On 02/25/13 01:22, Antti Palosaari wrote:
> [=E2=80=A6]
> >>> Poma, you should probably just start filing bugs for things you h=
it.
> >>> In this case, the skge backtrace is just a warning but it can be =
fixed
> >>> up relatively easily.
> >>>
> >>
> >> https://bugzilla.redhat.com/show_bug.cgi?id=3D914994
> >> Josh, Mauro thanks for the overview. :)
> >> Antti, cheers. ;)
> >>
> >> poma
> >=20
> > I cannot see these warnings at all. What is Kernel option to enable
> > those debug(?) warnings? From which menu it could be located when m=
ake
> > menuconfig ?
> >=20
>=20
> http://kojipkgs.fedoraproject.org/packages/kernel/3.9.0/0.rc0.git7.1.=
fc19/data/logs/x86_64/build.log
> Even after reapplying Stephen's "skge: check for PCI dma mapping
> errors"[1] from David's 'net-next' tree, no luck.
> =E2=80=A6
> WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x960()
> skge 0000:01:09.0: DMA-API: device driver failed to check map
> error[device address=3D0x000000010287094a] [size=3D90 bytes] [mapped =
as single]
> =E2=80=A6

I'm confused.  You pointed to the build I did this morning, which
definitely doesn't include the commit you mentioned.  Are you saying yo=
u
took this morning's build and applied the patch yourself?  If so, did i=
t
really get applied?  Do you have logs?  Do you have more than just that
tiny snippet of error message?

josh
