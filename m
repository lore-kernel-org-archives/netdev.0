From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 07:04:33 -0700
Message-ID: <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
References: <606676310904291600u40e44187g4cfc104007b24fce@mail.gmail.com>
	 <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jelaas@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:53749 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763253AbZD3OEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 10:04:33 -0400
Received: by rv-out-0506.google.com with SMTP id f6so2835905rvb.5
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 07:04:33 -0700 (PDT)
In-Reply-To: <20090430.022417.07019547.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<snip>

> If all the TX activity is happening on one TX queue then
> there is a bug somewhere.
>
> Either the receiving device isn't invoking skb_record_rx_queue()
> correctly, or there is some bug in how we compute the TX hash.

 I'll do some debugging around skb_tx_hash() and see if I can make
sense of it.  I'll let you know what I find.  My hypothesis is that
skb_record_rx_queue() isn't being called, but I should dig into it
before I start making claims. ;-P

<snip>
