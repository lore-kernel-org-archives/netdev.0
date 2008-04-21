From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC: 2.6 patch] remove ieee80211_tx_frame()
Date: Mon, 21 Apr 2008 12:54:39 -0400
Message-ID: <1208796879.30994.18.camel@localhost.localdomain>
References: <20080421084828.GO26897@cs181133002.pp.htv.fi>
	 (sfid-20080421_094925_772393_0D4181DC)  <1208769203.26186.56.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	James Ketrenos <jketreno@linux.intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60733 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755134AbYDUQ6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 12:58:33 -0400
In-Reply-To: <1208769203.26186.56.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-21 at 11:13 +0200, Johannes Berg wrote:
> On Mon, 2008-04-21 at 11:48 +0300, Adrian Bunk wrote:
> > After the softmac removal ieee80211_tx_frame() was no longer used.
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> Hmm. It wasn't added as part of softmac so must have been around longer,
> not sure. James?

Not used by ipw2100/2200/2915 (only ieee80211 users left), so it can
probably go.

Dan


