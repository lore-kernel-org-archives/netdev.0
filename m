From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Wed, 12 Jul 2006 18:53:31 +0200
Message-ID: <20060712185331.0573b1b1@griffin.suse.cz>
References: <200607110054.36520.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50074 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751456AbWGLQxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 12:53:33 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200607110054.36520.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jul 2006 00:54:33 +0200, Michael Buesch wrote:
> Please apply this to wireless-dev.
> Note that this is the second try to submit this patch.
> The first try contained a little bug. I'm sorry for that.
> If you already applied the first one, I can provide an incremental patch.
> 
> Note2 that this patch depends on the
> [PATCH] cancel_rearming_delayed_work infinite loop fix
> I just sent out to the lists and akpm.

I'm still digging through this. But I think it is not necessary to use
cancel_rearming_delayed_work at all; will try to make a patch.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
