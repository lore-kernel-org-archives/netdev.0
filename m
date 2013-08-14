From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only real link-local addresses
Date: Wed, 14 Aug 2013 23:17:01 +0200
Message-ID: <20130814211658.GA2075@x61s.8.8.8.8>
References: <1376478067-3371-1-git-send-email-alex.aring@gmail.com>
 <20130814.125346.585011183381258117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:34352 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760012Ab3HNVNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 17:13:14 -0400
Received: by mail-ea0-f170.google.com with SMTP id h14so5101532eak.29
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 14:13:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130814.125346.585011183381258117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Aug 14, 2013 at 12:53:46PM -0700, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Wed, 14 Aug 2013 13:01:07 +0200
> 
> > A link-local address isn't fe80::/10 it's fe80::/64
> > see http://tools.ietf.org/html/rfc4291#section-2.5.6
> > for more details.
> > 
> > Also fix a comment issue "local link" -> "link-local"
> > 
> > Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> > Reviewed-by: Werner Almesberger <werner@almesberger.net>
> 
> You still haven't addressed my biggest concern.
> 
Sorry, I thought that was the missing "net-next" tag in the subject.

> What order do I apply this patch relative to the other 6?
> 
This patch is a fix for the compression of an address. To make the right
compression on a link-local address.

So this patch has nothing to do for the address uncompression fix
(the patch serie should fix the uncompression of addresses). This is a
bigger patch serie because we make a major rewrite of this function.

The order doesn't matter for this patch. Necessary is that the patch
series will apply in the order 1 to 6. So you can apply this patch
before or afterwards the patch-series.

> Don't make me guess, instead place this patch into the necessary
> place within the series of 6 patches.
> 
I can understand that. This patches only fixes some address behaviour
which is in the current implementation wrong. But there are several
other problems with the current 6LoWPAN implementation.
I don't know which is the right place for these patches, because it is
a big change and the 6LoWPAN implementation is broken anyway.

> I'm not applying any of this until you can submit it properly.
> 
Ok, please let me know what should I do to submit it properly.

Thanks

Regards
Alex
