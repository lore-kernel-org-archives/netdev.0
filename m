From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: restore 1.5x per RTT limit to CUBIC cwnd
 growth in congestion avoidance
Date: Wed, 11 Mar 2015 21:17:38 -0400 (EDT)
Message-ID: <20150311.211738.171700356008439310.davem@davemloft.net>
References: <1426022224-28793-2-git-send-email-ncardwell@google.com>
	<20150311.165214.2047968573920569481.davem@davemloft.net>
	<CADVnQy=5_8tY+_7k+LcUC=MBtbBnSMeS2yq6na51Qx6Ex=b_Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502AbbCLBRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:17:43 -0400
In-Reply-To: <CADVnQy=5_8tY+_7k+LcUC=MBtbBnSMeS2yq6na51Qx6Ex=b_Tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 11 Mar 2015 18:10:42 -0400

> My sense is that both of these fixes are appropriate for the stable
> queue, since they fix serious packet loss issues that folks running
> 3.19.x will run into:

Ok, queued up, thanks.
