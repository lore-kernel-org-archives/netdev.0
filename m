From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Sat, 15 Apr 2006 18:47:35 +0100
Message-ID: <20060415174734.GA10595@infradead.org>
References: <443EF3E9.7050303@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffl@comix.santa-cruz.ca.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:22421 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030299AbWDORr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 13:47:57 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <443EF3E9.7050303@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 07:59:21PM -0500, Larry Finger wrote:
> I am planning on writing a new routine to be added to 
> net/ieee80211/ieee80211_geo.c that will populate an ieee80211_geo object 
> given a country code. The new routine will eliminate the need for each 
> driver to do their own.

This sounds like a generally good idea, but the question is:  do we want
this inside a kernel module or in userspace, either like the regulartory
daemon intel has (unfortunately in binary only form) or as a simple init
script.  I really don't want to recompile my kernel just because regulations
changed, and they seems to do that quite often.

