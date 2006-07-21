From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 02:19:55 -0700 (PDT)
Message-ID: <20060721.021955.104040230.davem@davemloft.net>
References: <20060721071009.GA5151@2ka.mipt.ru>
	<20060721.004713.71097915.davem@davemloft.net>
	<20060721090610.GF5151@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22695
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030430AbWGUJT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 05:19:56 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060721090610.GF5151@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 21 Jul 2006 13:06:11 +0400

> Receiving side, nor matter if it is socket or netchannel, will drop
> packets (socket due to queue overfull, netchannels will not drop, but
> will not ack (it's maximum queue len is 1mb)).
> 
> So both approaches behave _exactly_ the same.
> Did I miss something?

Socket will not drop the packets on receive because sender will not
violate the window which receiver advertises, therefore there is no
reason to drop the packets.
