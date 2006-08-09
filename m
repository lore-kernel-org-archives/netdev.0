From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: 3945 driver using d80211
Date: Wed, 9 Aug 2006 10:50:47 -0400
Message-ID: <20060809145042.GA2570@tuxdriver.com>
References: <44D901C9.6090304@linux.intel.com> <200608081440.48623.flamingice@sourmilk.net> <44D99558.1000507@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	Mohamed Abbas <mabbas@linux.intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:56071 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750907AbWHIOvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 10:51:55 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <44D99558.1000507@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 09:57:12AM +0200, Johannes Berg wrote:
> Michael Wu wrote:
> >I think it would be best if you made the firmware not be aware of a 
> >connection, and let the d80211 code take care of all the 
> >scanning/authenticating/associating. Of course, I know nothing about 3945, 
> >so I don't know if that's possible.
> >  
> Please not, for now. We need someone pushing for fullmac features in 
> d80211, we need those anyway for embedded systems that can't afford 
> running all of it on the main CPU. While obviously Intel would benefit 
> from doing this since a lot more d80211 features would come available, 
> the greater good would be having a main-stream card that someone cares 
> about and helps making d80211 full-mac capable.

I second this opinion.  It would be good to make d80211 more capable
of dealing with these cards.

John
-- 
John W. Linville
linville@tuxdriver.com
