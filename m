From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next 2011-09-19
Date: Mon, 19 Sep 2011 23:19:29 -0400
Message-ID: <20110920031929.GA2383@tuxdriver.com>
References: <20110919203639.GF2608@tuxdriver.com>
 <20110919.171124.1877822329573878893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kerenl.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38946 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070Ab1ITDaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 23:30:35 -0400
Content-Disposition: inline
In-Reply-To: <20110919.171124.1877822329573878893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2011 at 05:11:24PM -0400, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Mon, 19 Sep 2011 16:36:39 -0400
> 
> > Here is another big batch of updates intended for 3.2 -- still
> > clearing-out the backlog...
> > 
> > This round includes lots of updates to ath9k, b43, iwlagn, and rt2x00.
> > Some cleanups go to mac80211, along with a number of mesh-mode fixes
> > from Javier.
> > 
> > Please let me know if there are problems!
> 
> What about the iwl build failure reported by Eric Dumazet?
> 
> If that's not handled here, I want that fixed before we add even
> more regressions :-)

It's there. :-)

commit ff620849110649b5f94989ddfd7a72b2bd43bd42
Author: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Date:   Tue Sep 6 09:31:25 2011 -0700

    iwlagn: fix compilation when debug flags is unset
    
    Trivial fixes to allow compilation without warnings when debug
    compilation flag isn't set.
    Also fix the compilation when debugfs flag isn't set.
    Fix a warning: unused priv pointer on the way.
    
    Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
    Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
