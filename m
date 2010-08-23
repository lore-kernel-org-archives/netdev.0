From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: make TCP quick ACK behavior modifiable
Date: Mon, 23 Aug 2010 23:51:15 +0200
Message-ID: <20100823215115.GA2745@nuttenaction>
References: <1282590037-18566-1-git-send-email-hagen@jauu.net>
 <20100823121449.29419771@nehalam>
 <20100823200820.GB5896@nuttenaction>
 <20100823.142114.220045878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, ilpo.jarvinen@helsinki.fi,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:54009 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754117Ab0HWVvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 17:51:20 -0400
Content-Disposition: inline
In-Reply-To: <20100823.142114.220045878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller | 2010-08-23 14:21:14 [-0700]:

>> At least google inc is too busy to disable tcp quick ack's. And I
>> think they will save a lot of packets! Who make a bet? ;)
>
>I think assuming that turning off quick ACKs will be a net
>positive for google's traffic is a bit presumptuous, don't
>you?

bet? ;) The patch provides a switch to disable quick acks. If google or
someone else is using this switch or not is up to the audience! ;)

I don't know how many packets the current average HTTP session includes, but
assuming ~20 packets the saving of one packet is a benefit.
