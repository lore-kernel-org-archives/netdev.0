From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Wed, 12 Jul 2006 22:34:44 +0200
Message-ID: <200607122234.44309.mb@bu3sch.de>
References: <200607110054.36520.mb@bu3sch.de> <20060712185331.0573b1b1@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37550
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751158AbWGLUch
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:32:37 -0400
To: linville@tuxdriver.com, Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060712185331.0573b1b1@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 July 2006 18:53, Jiri Benc wrote:
> On Tue, 11 Jul 2006 00:54:33 +0200, Michael Buesch wrote:
> > Please apply this to wireless-dev.
> > Note that this is the second try to submit this patch.
> > The first try contained a little bug. I'm sorry for that.
> > If you already applied the first one, I can provide an incremental patch.
> > 
> > Note2 that this patch depends on the
> > [PATCH] cancel_rearming_delayed_work infinite loop fix
> > I just sent out to the lists and akpm.
> 
> I'm still digging through this. But I think it is not necessary to use
> cancel_rearming_delayed_work at all; will try to make a patch.

Jiri, so you care to get that patch upstream?
Would be cool, thanks.

John, do you manage to apply the bcm43xx init fix patch, which
depends on this one, to the tree after this one got in?
Or should I resend it?

-- 
Greetings Michael.
