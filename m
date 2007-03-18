From: Adrian Bunk <bunk@stusta.de>
Subject: [6/6] 2.6.21-rc4: known regressions
Date: Sun, 18 Mar 2007 19:49:38 +0100
Message-ID: <20070318184938.GZ752@stusta.de>
References: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	CIJOML <cijoml@volny.cz>, v4l-dvb-maintainer@linuxtv.org,
	Len Brown <lenb@kernel.org>, davem@davemloft.net,
	netdev@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Takashi Iwai <tiwai@suse.de>, perex@suse.cz,
	alsa-devel@alsa-project.org,
	Randy Cushman <rcushman_linux@earthlink.net>,
	Ismail =?utf-8?Q?D=C3=B6nmez?= <ismail@pardus.org.tr>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Thomas Meyer <thomas@m3y3r.de>,
	Greg Kroah-Hartman <gregkh@suse.de>, bcollins@debian.org,
	linux1394-devel@lists.sourceforge.net, Mark Lord <lkml@rtr.ca>,
	Jim Radford <radford@blackbean.org>,
	Oliver Neukum <oneukum@suse.de>,
	linux-usb-devel@lists.sourceforge.net,
	Catalin Marinas <catalin.marinas@gmail.com>,
	"Eri
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932953AbXCRSuZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.=
20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering=
=2E


Subject    : Oops when changing DVB-T adapter
References : http://lkml.org/lkml/2007/3/9/212
Submitter  : CIJOML <cijoml@volny.cz>
Status     : unknown


Subject    : ipv6 crash
References : http://lkml.org/lkml/2007/3/10/2
Submitter  : Len Brown <lenb@kernel.org>
Status     : unknown


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Handled-By : Ayaz Abdulla <aabdulla@nvidia.com>
Status     : submitter was asked to test a patch


Subject    : snd_intel8x0: divide error: 0000
References : http://lkml.org/lkml/2007/3/5/252
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Takashi Iwai <tiwai@suse.de>
Status     : problem is being debugged


Subject    : snd-intel8x0: no 3d surround sound
References : http://lkml.org/lkml/2007/3/5/164
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Caused-By  : Randy Cushman <rcushman_linux@earthlink.net>
             commit 831466f4ad2b5fe23dff77edbe6a7c244435e973
Handled-By : Takashi Iwai <tiwai@suse.de>
Status     : patch available


Subject    : Oops in __nodemgr_remove_host_dev
References : http://lkml.org/lkml/2007/3/14/4
             http://lkml.org/lkml/2007/3/18/87
Submitter  : Ismail D=C3=B6nmez <ismail@pardus.org.tr>
             Stefan Richter <stefanr@s5r6.in-berlin.de>
             Thomas Meyer <thomas@m3y3r.de>
Caused-By  : Greg Kroah-Hartman <gregkh@suse.de>
             commit 43cb76d91ee85f579a69d42bc8efc08bac560278
             commit 40cf67c5fcc513406558c01b91129280208e57bf
Handled-By : Stefan Richter <stefanr@s5r6.in-berlin.de>
Status     : problem is being debugged


Subject    : USB: Oops when connecting USB 1.1 docks
References : http://lkml.org/lkml/2007/3/4/266
Submitter  : Mark Lord <lkml@rtr.ca>
Caused-By  : Jim Radford <radford@blackbean.org>
             commit d9a7ecacac5f8274d2afce09aadcf37bdb42b93a
Handled-By : Oliver Neukum <oneukum@suse.de>
             Jim Radford <radford@blackbean.org>
Patch      : http://lkml.org/lkml/2007/3/13/217
Status     : patch available


Subject    : Possible "struct pid" leak from tty_io.c
References : http://lkml.org/lkml/2007/3/8/222
Submitter  : Catalin Marinas <catalin.marinas@gmail.com>
Caused-By  : Eric W. Biederman <ebiederm@xmission.com>
             commit ab521dc0f8e117fd808d3e425216864d60390500
Handled-By : Eric W. Biederman <ebiederm@xmission.com>
Status     : problem is being debugged
