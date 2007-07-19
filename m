From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: 2.6.22-git: known regressions with patches
Date: Thu, 19 Jul 2007 18:35:04 +0200
Message-ID: <469F92B8.5090809@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Giacomo Catenazzi <cate@cateee.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	Jens Axboe <axboe@suse.de>,
	"Peter M. Jones" <pjones@redhat.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	=?UTF-8?B?IlMuw4dhxJ9sYXIgT251?= =?UTF-8?B?ciI=?=
	<caglar@pardus.org.tr>, Meelis Roos <mroos@linux.ee>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:54576 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964921AbXGSQga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:36:30 -0400
Received: by ug-out-1314.google.com with SMTP id j3so445077ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:36:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.22-git
with patches available.

=46eel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            3
Andi Kleen                             2
Andrew Morton                          2
David Woodhouse                        2
Hugh Dickins                           2
Jens Axboe                             2


Unclassified

Subject         : disk error loop (panic?) ide_do_rw_disk-bad
References      : http://lkml.org/lkml/2007/7/17/467
Last known good : ?
Submitter       : Giacomo Catenazzi <cate@cateee.net>
Caused-By       : ?
Handled-By      : Jens Axboe <jens.axboe@oracle.com>
                  Linus Torvalds <torvalds@linux-foundation.org>
                  Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Patch           : http://lkml.org/lkml/2007/7/19/26
Status          : patch available

Subject         : Kconfig prompts without help text
References      : http://lkml.org/lkml/2007/7/16/326
Last known good : ?
Submitter       : Stefan Richter <stefanr@s5r6.in-berlin.de>
Caused-By       : ?
Handled-By      : Jan Engelhardt <jengelh@linux01.gwdg.de>
Patch           : http://lkml.org/lkml/2007/7/18/236
Status          : patch available



Block layer

Subject         : bsg.c:(.init.text+0x43d): undefined reference to `scs=
i_register_interface'
References      : http://lkml.org/lkml/2007/7/16/343
Last known good : ?
Submitter       : Larry Finger <Larry.Finger@lwfinger.net>
Caused-By       : ?
Handled-By      : S.=C3=87a=C4=9Flar Onur <caglar@pardus.org.tr>
Patch           : http://lkml.org/lkml/2007/7/16/380
Status          : patch available



=46S

Subject         : AFS compile broken
References      : http://lkml.org/lkml/2007/7/19/218
Last known good : ?
Submitter       : Meelis Roos <mroos@linux.ee>
Caused-By       : ?
Handled-By      : Cornelia Huck <cornelia.huck@de.ibm.com>
Patch           : http://lkml.org/lkml/2007/7/19/223
Status          : patch available



Networking

Subject         : net/sunrpc/auth_gss/auth_gss.c:100?: warning: implici=
t declaration of function '*_kernel'
References      : http://lkml.org/lkml/2007/7/14/78
Last known good : ?
Submitter       : Randy Dunlap <randy.dunlap@oracle.com>
Caused-By       : ?
Handled-By      : J. Bruce Fields <bfields@citi.umich.edu>
Patch           : http://lkml.org/lkml/2007/7/14/95
Status          : patch available



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
