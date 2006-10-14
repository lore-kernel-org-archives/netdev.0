From: Adrian Bunk <bunk@stusta.de>
Subject: [3/3] 2.6.19-r2: known regressions with patches
Date: Sat, 14 Oct 2006 13:34:09 +0200
Message-ID: <20061014113409.GL30596@stusta.de>
References: <Pine.LNX.4.64.0610130941550.3952@g5.osdl.org>
	<20061014111458.GI30596@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: fastboot@osdl.org, Arnd Bergmann <arnd.bergmann@de.ibm.com>,
   "Noguchi,
	Masato" <Masato.Noguchi@jp.sony.com>,
   Trond Myklebust <Trond.Myklebust@netapp.com>,
   Alex Romosan <romosan@sycorax.lbl.gov>,
   Torsten Kaiser <kernel@bardioc.dyndns.org>, ak@suse.de,
   Dave Kleikamp <shaggy@austin.ibm.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
   discuss@x86-64.org, ebiederm@xmission.com,
   linux-usb-devel@lists.sourceforge.net, Steve Fox <drfickle@us.ibm.com>,
   netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
   Magnus Damm <magnus.damm@gmail.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   lm-sensors@lm-sensors.org, Sukadev Bhattiprolu <sukadev@us.ibm.com>,
   Laurent Riffard <laurent.riffard@free.fr>,
   Sylvain BERTRAND <sylvain.bertrand@gmail.com>,
   Matthieu Castet <castet.matthieu@free.fr>,
   Jean Delvare <khali@linux-fr.org>, jgarzik@pobox.c
Return-path: <fastboot-bounces@lists.osdl.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061014111458.GI30596@stusta.de>
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

This email lists some known regressions in 2.6.19-rc2 compared to 2.6.18
with patches available.

Unless there are specific reasons against doing so, we should try to get =

these patches into -rc3.

(Especially the lad who wrote the patch for the third entry should ush =

 his patch...)

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possibly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : spufs: fix a memory leak
References : http://lkml.org/lkml/2006/10/10/63
Submitter  : "Noguchi, Masato" <Masato.Noguchi@jp.sony.com>
Caused-By  : Arnd Bergmann <arnd.bergmann@de.ibm.com>
             commit e1dbff2bafa83f839ef15f51904b0cce9fc89387
Handled-By : "Noguchi, Masato" <Masato.Noguchi@jp.sony.com>
Patch      : http://lkml.org/lkml/2006/10/10/63
Status     : patch available


Subject    : w83781d modprobing failure
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7293
Submitter  : Sylvain BERTRAND <sylvain.bertrand@gmail.com>
Caused-By  : David Hubbard <david.c.hubbard@gmail.com> (?)
             commit 8202632647278eba7223727dc442f49227c040d0 (?)
Handled-By : Jean Delvare <khali@linux-fr.org>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=3D7293
Status     : patch available


Subject    : drivers/char/specialix.c: broken baud conversion
References : http://lkml.org/lkml/2006/10/8/214
Submitter  : Adrian Bunk <bunk@stusta.de>
Caused-By  : Alan Cox <alan@lxorguk.ukuu.org.uk>
             commit 67cc0161ecc9ebee6eba4af6cbfdba028090b1b9
Handled-By : Adrian Bunk <bunk@stusta.de>
Patch      : http://lkml.org/lkml/2006/10/11/9
Status     : patch available


Subject    : ueagle-atm Oops
References : http://lkml.org/lkml/2006/10/6/390
Submitter  : Ernst Herzberg <list-lkml@net4u.de>
Caused-By  : Greg Kroah-Hartman <gregkh@suse.de>
             commit e7ccdfec087f02930c5cdc81143d4a045ae8d361
Handled-By : Matthieu Castet <castet.matthieu@free.fr>
             Laurent Riffard <laurent.riffard@free.fr>
Patch      : http://lkml.org/lkml/2006/10/11/209
Status     : patch available


Subject    : oops in xfrm_register_mode
References : http://lkml.org/lkml/2006/10/4/170
Submitter  : Steve Fox <drfickle@us.ibm.com>
Handled-By : Vivek Goyal <vgoyal@in.ibm.com>
Status     : patch available


Subject    : airo suspend fails
References : http://lkml.org/lkml/2006/10/6/3
Submitter  : Alex Romosan <romosan@sycorax.lbl.gov>
Caused-By  : Sukadev Bhattiprolu <sukadev@us.ibm.com>  (?)
             commit 3b4c7d640376dbccfe80fc4f7b8772ecc7de28c5  (?)
Handled-By : Dave Kleikamp <shaggy@austin.ibm.com>
Patch      : http://lkml.org/lkml/2006/10/7/139
Status     : patch available


Subject    : kexec broken on x86_64
References : http://lkml.org/lkml/2006/10/5/86
Submitter  : Magnus Damm <magnus.damm@gmail.com>
Handled-By : Vivek Goyal <vgoyal@in.ibm.com>
Patch      : http://lkml.org/lkml/2006/10/5/199
Status     : patch available


Subject    : NFSv4 fails to mount (timeout)
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D7274
Submitter  : Torsten Kaiser <kernel@bardioc.dyndns.org>
Caused-By  : Trond Myklebust <Trond.Myklebust@netapp.com>
             commit 51b6ded4d9a94a61035deba1d8f51a54e3a3dd86
Handled-By : Trond Myklebust <Trond.Myklebust@netapp.com>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=3D7274
Status     : patch available
