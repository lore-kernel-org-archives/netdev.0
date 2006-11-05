From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 1/6] d80211: change the cookie to be opaque
Date: Sun, 5 Nov 2006 16:20:29 +0100
Message-ID: <200611051620.29687.IvDoorn@gmail.com>
References: <20061102223854.692274000@sipsolutions.net> <1162514791.3381.14.camel@johannes.berg> <20061103041455.GE2989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:19332 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932693AbWKEPUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 10:20:42 -0500
Received: by ug-out-1314.google.com with SMTP id m3so708932ugc
        for <netdev@vger.kernel.org>; Sun, 05 Nov 2006 07:20:40 -0800 (PST)
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061103041455.GE2989@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 November 2006 05:15, John W. Linville wrote:
> On Fri, Nov 03, 2006 at 01:46:31AM +0100, Johannes Berg wrote:
> > 
> > > Ok, that one was wrong. But what is it doing in the public API? We need
> > > to remove it from the public API and leave struct net_device *dev as the
> > > parameter. adm8211 actually uses it and increases the tx_fifo_error
> > > counter, but that's a bit strange.
> > 
> > Fixed, and since, as always, netdev doesn't like my patches, they're
> > here instead:
> > 
> > http://johannes.sipsolutions.net/files/d80211-mdev-cleanup/
> > 
> > I also added d80211-reduce-mdev.patch which reduces stupid mdev usage,
> > but see the description in the patch itself.
> 
> 403 Forbidden (shouldn't that be Verboten? :-)
> 
> FWIW, I have the other 6 patches on the 'pending' branch of
> wireless-dev.  Driver authors, please proceed accordingly.

I am currently working on the fixes for rt2x00, the above patches look very good,
and also provide me with a chance to cleanup some garbage in rt2x00. :)
I'll make the patches for this part of my patch series which I will send to the netdev
list in 1 or 2 weeks. (I cannot do it any sooner due to school and work).

Ivo
