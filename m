From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.23-rc6: known regressions with patches
Date: Wed, 12 Sep 2007 18:59:14 +0200
Message-ID: <46E81AE2.8030802@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg KH <gregkh@suse.de>,
	Anssi Hannula <anssi.hannula@gmail.com>,
	David Woodhouse <dwmw2@infradead.org>,
	=?ISO-8859-2?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>,
	jamal <hadi@cyberus.ca>, linux-usb-devel@lists.sourceforge.net,
	Greg KH <gregkh@suse.de>,
	=?ISO-8859-2?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>,
	sean@mess.org, Adrian Bunk <bunk@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:9741 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934903AbXILRAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 13:00:04 -0400
Received: by fk-out-0910.google.com with SMTP id z23so230559fkz
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 10:00:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc6
with patches available.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            10
Linus Torvalds                         6
Alan Stern                             5
Andi Kleen                             5
Hugh Dickins                           5
Trond Myklebust                        5
Andrew Morton                          4
Al Viro                                3
Alexey Starikovskiy                    3
Cornelia Huck                          3
David S. Miller                        3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



Unclassified

Subject         : Oops while modprobing phy fixed module
References      : http://lkml.org/lkml/2007/7/14/63
Last known good : ?
Submitter       : Gabriel C <nix.or.die@googlemail.com>
Caused-By       : ?
Handled-By      : Satyam Sharma <satyam.sharma@gmail.com>
                  Vitaly Bordug <vitb@kernel.crashing.org>
Patch1          : http://lkml.org/lkml/2007/7/18/506
Status          : patch available



Drivercore

Subject         : sysfs change of input/event devices in 2.6.23rc break=
s udev
References      : http://lkml.org/lkml/2007/9/8/86
Last known good : ?
Submitter       : Anssi Hannula <anssi.hannula@gmail.com>
Caused-By       : ?
Handled-By      : Dmitry Torokhov <dmitry.torokhov@gmail.com>
Patch           : http://lkml.org/lkml/2007/9/10/3
Status          : patch available



MTD

Subject         : include/linux/mtd/map.h:128:2: error: #error "No bus =
width supported. What's the point?"
References      : http://lkml.org/lkml/2007/9/11/151
Last known good : ?
Submitter       : Toralf F=F6rster <toralf.foerster@gmx.de>
Caused-By       : ?
Handled-By      : ?
Patch           : http://git.infradead.org/?p=3Dmtd-2.6.git;a=3Dcommit;=
h=3D241651d04d672fb685b2874707016cbbf95931e5
Status          : patch available



Networking

Subject         : 2.6.23-rc5: possible irq lock inversion dependency de=
tected
References      : http://lkml.org/lkml/2007/9/2/97
Last known good : ?
Submitter       : Christian Kujau <lists@nerdbynature.de>
Caused-By       : ?
Handled-By      : jamal <hadi@cyberus.ca>
Patch           : http://lkml.org/lkml/2007/9/11/159
Status          : patch available



USB

Subject         : build #246 failed for 2.6.23-rc6-g0d4cbb5 in linux/dr=
ivers/usb/misc/phidgetservo.ko
References      : http://lkml.org/lkml/2007/9/11/211
Last known good : ?
Submitter       : Toralf F=F6rster <toralf.foerster@gmx.de>
Caused-By       : ?
Handled-By      : Adrian Bunk <bunk@kernel.org>
Patch           : http://lkml.org/lkml/2007/9/11/284
Status          : patch available



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
