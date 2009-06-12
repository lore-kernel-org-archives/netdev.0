From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: lots of cpu time spent in skb_copy_bits() in net-next with small
 mtu
Date: Fri, 12 Jun 2009 22:57:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906122248450.31625@melkinkari.cs.Helsinki.FI>
References: <20090612161320.GB4290@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Benjamin LaHaise <ben.lahaise@neterion.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36773 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561AbZFLT5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 15:57:40 -0400
In-Reply-To: <20090612161320.GB4290@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Jun 2009, Benjamin LaHaise wrote:

> Just a heads up: something in net-next is resulting in lots of cpu time 
> being spent in skb_copy_bits() (called from tcp_collapse()) when an ethernet 
> interface mtu is lowered to 576 on the source and dest machines running 
> netperf.  This behaviour does not appear in 2.6.29.  I'll try to bisect 
> it this weekend.

I'd suggest somebody goes through DaveM's abstraction patch 915219441d56 
(I'm totally out of time so somebody else has to do it if a timely 
solution is desired)... It was quite messy on those parts and I already 
found one issue from it (2df9001edc3) and wouldn't be too surprised if 
there would be some more lurking around... 


-- 
 i.
