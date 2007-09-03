From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/2] 2.6.23-rc5: known regressions with patches
Date: Mon, 03 Sep 2007 12:11:18 +0200
Message-ID: <46DBDDC6.9030602@googlemail.com>
References: <46DBDCF4.6040805@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kbuild-devel@lists.sourceforge.net,
	Roman Zippel <zippel@linux-m68k.org>,
	Sam Ravnborg <sam@ravnborg.org>,
	Hugh Dickins <hugh@veritas.com>,
	Pierre Ossman <drzeus-mmc@drzeus.cx>,
	Christian Casteyde <casteyde.christian@free.fr>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-mtd@lists.infradead.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@sunset.davemloft.net>,
	netdev@vger.kernel.org, Mark Hindley <mark@hindley.org.uk>,
	linux-ide@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Grant Wilson <grant.wilson@zen.co.uk>,
	Ondrej Zary <linux@rainbow-software.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:33534 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758185AbXICKMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2007 06:12:02 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1468714wxd
        for <netdev@vger.kernel.org>; Mon, 03 Sep 2007 03:12:01 -0700 (PDT)
In-Reply-To: <46DBDCF4.6040805@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc5
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            9
Linus Torvalds                         6
Andi Kleen                             5
Hugh Dickins                           5
Andrew Morton                          4
Al Viro                                3
Alan Stern                             3
Alexey Starikovskiy                    3
Cornelia Huck                          3
Jens Axboe                             3
Stephen Hemminger                      3
Tejun Heo                              3



Kconfig

Subject         : CONFIG_HOTPLUG_CPU: kconfig bug?
References      : http://lkml.org/lkml/2007/8/27/204
Last known good : ?
Submitter       : Hugh Dickins <hugh@veritas.com>
Caused-By       : ?
Handled-By      : Roman Zippel <zippel@linux-m68k.org>
                  Sam Ravnborg <sam@ravnborg.org>
Patch           : http://lkml.org/lkml/2007/8/29/301
Status          : patch available



MMC

Subject         : Unable to access memory card reader anymore
References      : http://bugzilla.kernel.org/show_bug.cgi?id=8885
Last known good : ?
Submitter       : Christian Casteyde <casteyde.christian@free.fr>
Caused-By       : ?
Handled-By      : Alan Stern <stern@rowland.harvard.edu>
Patch           : http://bugzilla.kernel.org/attachment.cgi?id=12438
Status          : patch available



MTD

Subject         : error: implicit declaration of function 'cfi_interleave'
References      : http://lkml.org/lkml/2007/8/6/272
Last known good : ?
Submitter       : Ingo Molnar <mingo@elte.hu>
Caused-By       : ?
Handled-By      : David Woodhouse <dwmw2@infradead.org>
Patch           : http://lkml.org/lkml/2007/8/9/586
Status          : patch available



Networking

Subject         : [OOPS] 2.6.23-rc5 ? network/via-rhine
References      : http://lkml.org/lkml/2007/9/2/58
Last known good : ?
Submitter       : Mark Hindley <mark@hindley.org.uk>
Caused-By       : ?
Handled-By      : David S. Miller <davem@sunset.davemloft.net>
Patch           : http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=5c127c58ae9bf196d787815b1bd6b0aec5aee816
Status          : patch available



PATA/SATA

Subject         : sata_via: write errors on PATA drive connected to VT6421
References      : http://lkml.org/lkml/2007/8/20/248
Last known good : ?
Submitter       : Ondrej Zary <linux@rainbow-software.org>
Caused-By       : ?
Handled-By      : Ondrej Zary <linux@rainbow-software.org>
Patch           : http://lkml.org/lkml/2007/8/31/310
Status          : patch available

Subject         : NULL pointer dereference in ata_piix
References      : http://lkml.org/lkml/2007/9/1/33
Last known good : ?
Submitter       : Grant Wilson <grant.wilson@zen.co.uk>
Caused-By       : ?
Handled-By      : Jeff Garzik <jeff@garzik.org>
Patch           : http://lkml.org/lkml/2007/9/1/46
Status          : patch available



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
