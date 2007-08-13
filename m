From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: [2/2] 2.6.23-rc3: known regressions with patches
Date: Mon, 13 Aug 2007 20:00:03 +0200
Message-ID: <46C09C23.8070906@googlemail.com>
References: <46C09B4D.6040907@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Jan Dittmer <jdi@l4x.org>,
	Thomas Renninger <trenn@suse.de>,
	linux-mtd@lists.infradead.org,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Tony Luck <tony.luck@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Florian Lohoff <flo@rfc822.org>,
	linux-usb-devel@lists.sourceforge.net, Greg KH <gregkh@suse.de>,
	Alan Stern <stern@rowland.harvard.edu>,
	Dan Zwell <dzwell@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:35699 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965509AbXHMSBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 14:01:11 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1475659fkz
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 11:01:08 -0700 (PDT)
In-Reply-To: <46C09B4D.6040907@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Here is a list of some known regressions in 2.6.23-rc3
with patches available.

Feel free to add new regressions/remove fixed etc.
http://kernelnewbies.org/known_regressions

List of Aces

Name                    Regressions fixed since 21-Jun-2007
Adrian Bunk                            9
Andi Kleen                             5
Linus Torvalds                         5
Andrew Morton                          4
Al Viro                                3
Cornelia Huck                          3
Jens Axboe                             3
Tejun Heo                              3



Modpost

Subject         : modpost bug breaks ia64 cross compilation
References      : http://lkml.org/lkml/2007/7/27/30
                  http://lkml.org/lkml/2007/7/27/418
Last known good : ?
Submitter       : Jan Dittmer <jdi@l4x.org>
Caused-By       : Thomas Renninger <trenn@suse.de>
                  commit 29b71a1ca74491fab9fed09e9d835d840d042690
Handled-By      : ?
Patch           : http://lkml.org/lkml/2007/8/2/211
Status          : patch was suggested



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

Subject         : sky2 boot crash in sky2_mac_intr
References      : http://lkml.org/lkml/2007/7/24/91
Last known good : ?
Submitter       : Florian Lohoff <flo@rfc822.org>
Caused-By       : 
Handled-By      : Stephen Hemminger <shemminger@osdl.org>
Patch           : http://marc.info/?l=linux-netdev&m=118651402523966&w=2
Status          : patch available



USB

Subject         : USB hard disk problem due to "usb-storage: implement autosuspend" patch
References      : http://lkml.org/lkml/2007/8/9/329
Last known good : ?
Submitter       : Dan Zwell <dzwell@gmail.com>
Caused-By       : Alan Stern <stern@rowland.harvard.edu>
                  commit 8dfe4b14869fd185ca25ee88b02ada58a3005eaf
Handled-By      : Alan Stern <stern@rowland.harvard.edu>
Status          : patch available



Regards,
Michal

--
LOG
http://www.stardust.webpages.pl/log/
