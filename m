From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 3/12] d80211: separate allocation of ieee80211_local
Date: Mon, 12 Jun 2006 15:52:05 -0400
Message-ID: <20060612195200.GB14851@tuxdriver.com>
References: <20060608094822.014829000.midnight@suse.cz> <20060608074907.2CB5B48391@silver.suse.cz> <20060612213523.473a9714@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:14097
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S932163AbWFLTwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 15:52:30 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060612213523.473a9714@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 09:35:23PM +0200, Jiri Benc wrote:
> On Thu,  8 Jun 2006 09:49:07 +0200 (CEST), Jiri Benc wrote:
> > ieee80211_local has a separate class_device. That means it has reference
> > counting independent of master net_device and can be freed at a different
> > time, therefore these two structures cannot be allocated together.
> > 
> > Solve this by adding ieee80211_ptr pointer to net_device structure (similar
> > to other pointers already presented there) and using it as a pointer to
> > independently allocated ieee80211_local.
> 
> I suppose approval from Dave will be needed for adding that pointer to
> net_device, right?

Ulitmately, yes. :-)

John
-- 
John W. Linville
linville@tuxdriver.com
