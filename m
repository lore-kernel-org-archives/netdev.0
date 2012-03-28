From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] f_phonet: fix skb truesize underestimation
Date: Wed, 28 Mar 2012 05:33:10 -0400 (EDT)
Message-ID: <20120328.053310.219141897175161116.davem@davemloft.net>
References: <1332853442.3248.15.camel@edumazet-laptop>
	<20120327.225109.752822925052179338.davem@davemloft.net>
	<20120328085535.GF18156@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	remi.denis-courmont@nokia.com
To: balbi@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238Ab2C1Jd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 05:33:26 -0400
In-Reply-To: <20120328085535.GF18156@arwen.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felipe Balbi <balbi@ti.com>
Date: Wed, 28 Mar 2012 11:55:36 +0300

> On Tue, Mar 27, 2012 at 10:51:09PM -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 27 Mar 2012 06:04:02 -0700
>> 
>> > Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet to
>> > properly account truesize of each fragment : a full page.
>> > 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Applied.
> 
> did you apply both patches ?

You never need to ask me these kinds of questions, you can
either check my GIT tree or look at:

http://patchwork.ozlabs.org/project/netdev/list/?state=3
