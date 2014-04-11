From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] mvneta: software TSO implementation
Date: Fri, 11 Apr 2014 12:58:38 -0400 (EDT)
Message-ID: <20140411.125838.2303458258387254900.davem@davemloft.net>
References: <20140411054847.GE30855@1wt.eu>
	<20140411.022006.1718259701974368498.davem@davemloft.net>
	<20140411063021.GH30855@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ezequiel.garcia@free-electrons.com,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	tawfik@marvell.com, alior@marvell.com
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422731AbaDKQ6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 12:58:43 -0400
In-Reply-To: <20140411063021.GH30855@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Fri, 11 Apr 2014 08:30:21 +0200

> Do you think for example that having an xmit_tso() function which would
> iterate over all segments and call something like :
>    ->build_hdr()
>    ->build_data()
>    ->unroll_all()
> 
> would be sufficient ?

Yes, something involving callbacks is probably going to be necessary.

> I think that the fact you want to do it for NIU is a good opportunity
> to try to do it the right way in the most generic mode, but we'll
> surely need your help on this!

I can help for sure :)
