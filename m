From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Thu, 2 Nov 2006 23:15:01 -0500
Message-ID: <20061103041455.GE2989@tuxdriver.com>
References: <20061102223854.692274000@sipsolutions.net> <20061102230013.960383000@sipsolutions.net> <1162513367.3381.11.camel@johannes.berg> <1162514791.3381.14.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:30991 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751059AbWKCEYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 23:24:45 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1162514791.3381.14.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 03, 2006 at 01:46:31AM +0100, Johannes Berg wrote:
> 
> > Ok, that one was wrong. But what is it doing in the public API? We need
> > to remove it from the public API and leave struct net_device *dev as the
> > parameter. adm8211 actually uses it and increases the tx_fifo_error
> > counter, but that's a bit strange.
> 
> Fixed, and since, as always, netdev doesn't like my patches, they're
> here instead:
> 
> http://johannes.sipsolutions.net/files/d80211-mdev-cleanup/
> 
> I also added d80211-reduce-mdev.patch which reduces stupid mdev usage,
> but see the description in the patch itself.

403 Forbidden (shouldn't that be Verboten? :-)

FWIW, I have the other 6 patches on the 'pending' branch of
wireless-dev.  Driver authors, please proceed accordingly.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
