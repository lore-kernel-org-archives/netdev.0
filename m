From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: [1/2] 2.6.23-rc1: known regressions
Date: Mon, 23 Jul 2007 11:47:30 +0200
Message-ID: <46A47932.8000709@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>,
	Ingo Molnar <mingo@elte.hu>, Markus <lists4me@web.de>,
	Andre Noll <maan@systemlinux.org>,
	acpi4asus-user@lists.sourceforge.net,
	Corentin Chary <corentincj@iksaif.net>,
	Karol Kozimor <sziwan@users.sourceforge.net>,
	Gabriel C <nix.or.die@googlemail.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Thomas Meyer <thomas@m3y3r.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:12553 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838AbXGWJtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 05:49:41 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1140672ugf
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 02:49:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc1.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Andi Kleen                             4
Linus Torvalds                         4
Adrian Bunk                            3
Andrew Morton                          3
Jens Axboe                             3
Al Viro                                2
David Woodhouse                        2
Hugh Dickins                           2
Tejun Heo                              2



Unclassified

Subject         : /usr/bin/ld: section .text [ffffffffff700500 -> ffffffffff7007e3] overlaps section .gnu.version_d [ffffffffff7004d8 -> ffffffffff70050f]
References      : http://lkml.org/lkml/2007/7/22/239
Last known good : ?
Submitter       : Andre Noll <maan@systemlinux.org>
Caused-By       : ?
Handled-By      : Andi Kleen <ak@suse.de>
Status          : problem is being debugged

Subject         : pcwd_init_module(): WARNING: at lib/kref.c:33 kref_get()
References      : http://lkml.org/lkml/2007/7/22/94
Last known good : ?
Submitter       : Ingo Molnar <mingo@elte.hu>
Caused-By       : ?
Handled-By      : ?
Status          : problem is being debugged

Subject         : konqueror suddenly vanishing, "konqueror: Fatal IO error: client killed"
References      : http://lkml.org/lkml/2007/7/22/86
Last known good : ?
Submitter       : Markus <lists4me@web.de>
Caused-By       : ?
Handled-By      : Ingo Molnar <mingo@elte.hu>
Status          : problem is being debugged



ACPI

Subject         : drivers/misc/asus-laptop.c:*: error: 'struct led_classdev' has no member named 'class_dev'
References      : http://lkml.org/lkml/2007/7/22/299
Last known good : ?
Submitter       : Gabriel C <nix.or.die@googlemail.com>
Caused-By       : ?
Handled-By      : ?
Status          : unknown



Networking

Subject         : New wake ups from sky2
References      : http://lkml.org/lkml/2007/7/20/386
Last known good : ?
Submitter       : Thomas Meyer <thomas@m3y3r.de>
Caused-By       : Stephen Hemminger <shemminger@osdl.org>
                  commit eb35cf60e462491249166182e3e755d3d5d91a28
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Status          : unknown



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
