From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Fri, 28 Aug 2015 22:14:17 -0700 (PDT)
Message-ID: <20150828.221417.905062374709400810.davem@davemloft.net>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
	<1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbbH2FOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 01:14:18 -0400
In-Reply-To: <1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Aug 2015 18:31:07 -0700

> On Fri, 2015-08-28 at 17:34 -0700, David Ahern wrote:
>> Currently the VRF driver registers an Rx handler for enslaved devices.
>> The handler switches the skb->dev to the VRF device and sends it back for
>> another pass. While this works fine a side effect is that it bypasses
>> netfilter with the skb set to the original device.
>> 
> 
> Arg ... yet another hook in packet processing fast path...
> 
> What are long term plans for VRF ? Will it stay VRF-Lite or what ?

+1
