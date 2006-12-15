From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] p54: Fix compilation for d80211 hwmode API change
Date: Fri, 15 Dec 2006 23:37:41 +0100
Message-ID: <200612152337.41669.mb@bu3sch.de>
References: <200612152045.36135.mb@bu3sch.de> <200612151638.24454.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, John Linville <linville@tuxdriver.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37821
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965281AbWLOWiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 17:38:20 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200612151638.24454.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 15 December 2006 22:38, Michael Wu wrote:
> On Friday 15 December 2006 14:45, Michael Buesch wrote:
> > This fixes compilation for the d80211 hwmode API change.
> >
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> >
> We can't specify modes before device registration now? There would be less 
> duplicated code here if we could.

Well, actually, rt2x00 driver called update_hw before
register_hw (which is not required, but it did it).
So I think we can also call register_hwmode before
register_hw now, as register_hwmode basically does
nothing more than update_hw.

So, I think it should also work, if you call register_hwmode
before register_hw. Jiri?

-- 
Greetings Michael.
