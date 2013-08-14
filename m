From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] [PATCH] 6lowpan: handle only real
 link-local addresses
Date: Wed, 14 Aug 2013 07:24:36 -0300
Message-ID: <20130814102436.GJ21958@ws>
References: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
 <20130813.151230.1608414279292576217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alex.aring@gmail.com, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:42084 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162Ab3HNK1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 06:27:05 -0400
Content-Disposition: inline
In-Reply-To: <20130813.151230.1608414279292576217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> You're submitting 7 patches, one set is numbered 1-6 and this
> one has no number.

The unnumbered patch is independent from the rest. But yes, he
shouldn't have sent it in the same thread.

To provide a bit of context, 6LoWPAN support in the kernel is
currently in an embarrassingly badly broken state. On a good day,
you can get ping to an RFC-compliant peer to work, sometimes even
both ways, but only as long as you use link-local addresses and
keep the payload small. Beyond that, it's all bugland.

Alexander thus started to fix the 6LoWPAN issues he and others,
myself included, had bumped into. It's a lot of changes for a
relatively small file (6lowpan.c) and later on he'll have at
least one more batch for fragmentation, but when all that is
done, we'll finally have a stack that can actually do real work.

Alexander, since you'll have to re-submit anyway, you may want to
add a

Reviewed-by: Werner Almesberger <werner@almesberger.net>

to all the patches.

- Werner
