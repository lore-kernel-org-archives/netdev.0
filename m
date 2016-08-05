From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Buggy rhashtable walking
Date: Fri, 05 Aug 2016 12:50:33 +0200
Message-ID: <1470394233.2977.37.camel@sipsolutions.net>
References: <20160804071846.GA773@gondor.apana.org.au>
 <20160804074546.GA996@gondor.apana.org.au>
 <1470377813.2977.14.camel@sipsolutions.net>
	 <20160805104858.GA9297@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	tom@herbertland.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37372 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934745AbcHEKum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 06:50:42 -0400
In-Reply-To: <20160805104858.GA9297@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-05 at 18:48 +0800, Herbert Xu wrote:
> On Fri, Aug 05, 2016 at 08:16:53AM +0200, Johannes Berg wrote:
> > 
> > Hm. Would you rather allocate a separate head entry for the
> > hashtable,
> > or chain the entries?
> 
> My plan is to build support for this directly into rhashtable.
> So I'm adding a struct rhlist_head that would be used in place
> of rhash_head for these cases and it'll carry an extra pointer
> for the list of identical entries.
> 
> I will then add an additional layer of insert/lookup interfaces
> for rhlist_head.

Oh, ok.

> So bottom-line is that if you have no identical entries that you
> only incur an extra 8 bytes per-object.
> 
Right.

Thanks!

johannes
