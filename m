From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: 2.6.19-rc1: known regressions (v2)
Date: Sun, 08 Oct 2006 10:56:39 +0200
Message-ID: <4528BD47.5030509@free.fr>
References: <Pine.LNX.4.64.0610042017340.3952@g5.osdl.org>
	<20061007214620.GB8810@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: len.brown@intel.com, alsa-devel@alsa-project.org,
   Thierry Vignaud <tvignaud@mandriva.com>, linux-pm@osdl.org,
   Benjamin Herrenschmidt <benh@kernel.crashing.org>,
   Alex Romosan <romosan@sycorax.lbl.gov>,
   Torsten Kaiser <kernel@bardioc.dyndns.org>, Olaf Hering <olaf@aepfle.de>,
   ak@suse.de, linux-ide@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>,
   fastboot@osdl.org, Dave Kleikamp <shaggy@austin.ibm.com>,
   Pavel Machek <pavel@ucw.cz>, Antonino Daplas <adaplas@pol.net>,
   linux1394-devel@lists.sourceforge.net, perex@suse.cz,
   Alistair John Strachan <s0348365@sms.ed.ac.uk>, discuss@x86-64.org,
   linux-fbdev-devel@lists.sourceforge.net,
   linux-usb-devel@lists.sourceforge.net,
   Trond Myklebust <Trond.Myklebust@netapp.com>, linuxppc-dev@ozlabs.org,
   Steve Fox <drfickle@us.ibm.com>, netdev@vger.kernel.org,
   Magnus Damm <magnus.damm@gmail.com>,
   Linux Kernel
Return-path: <fastboot-bounces@lists.osdl.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061007214620.GB8810@stusta.de>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/fastboot>,
	<mailto:fastboot-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/fastboot>
List-Post: <mailto:fastboot@lists.osdl.org>
List-Help: <mailto:fastboot-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/fastboot>,
	<mailto:fastboot-request@lists.osdl.org?subject=subscribe>
Sender: fastboot-bounces@lists.osdl.org
Errors-To: fastboot-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

Hi,

Adrian Bunk wrote:
> This email lists some known regressions in 2.6.19-rc1 compared to 2.6.18
> that are not yet fixed Linus' tree.
> =

> If you find your name in the Cc header, you are either submitter of one
> of the bugs, maintainer of an affectected subsystem or driver, a patch
> of you was declared guilty for a breakage or I'm considering you in any
> other way possibly involved with one or more of these issues.
> =

> Due to the huge amount of recipients, please trim the Cc when answering.
> =

> =


> =

> Subject    : ueagle-atm Oops
> References : http://lkml.org/lkml/2006/10/6/390
> Submitter  : Ernst Herzberg <list-lkml@net4u.de>
> Handled-By : Matthieu Castet <castet.matthieu@free.fr>
> Status     : unknown
> =

> =

Guilty     :
http://www.kernel.org/git/gitweb.cgi?p=3Dlinux/kernel/git/torvalds/linux-2.=
6.git;a=3Dcommitdiff;h=3De7ccdfec087f02930c5cdc81143d4a045ae8d361

Patch available at =

https://mail.gna.org/public/ueagleatm-dev/2006-10/msg00022.html , but =

some cleaning is need (I wasn't aware of "USB: fix __must_check warnings =

in drivers/usb/atm/" patch).

Matthieu
