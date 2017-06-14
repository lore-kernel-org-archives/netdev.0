From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Wed, 14 Jun 2017 22:40:29 +0200
Message-ID: <1497472829.9377.13.camel@sipsolutions.net>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <1497472613.18751.67.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:41532 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751974AbdFNUkb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 16:40:31 -0400
In-Reply-To: <1497472613.18751.67.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 13:36 -0700, Joe Perches wrote:
> 
> Given you are adding a lot of these, it might be better
> to add an exported function that duplicates most of
> skb_put with a memset at the end.

Yeah, could be done. I'm not sure why you'd want to duplicate it rather
than call it though? To make it about as fast?

Anyway, no objections really - just originally thought of it more as a
typing aid than an optimisation.

johannes
