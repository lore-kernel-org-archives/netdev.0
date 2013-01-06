From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sat, 05 Jan 2013 17:21:16 -0800
Message-ID: <1357435276.1678.5067.camel@edumazet-glaptop>
References: <20130105214958.GA19814@1wt.eu>
	 <1357427926.1678.4771.camel@edumazet-glaptop>
	 <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48419 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754757Ab3AFBVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 20:21:20 -0500
In-Reply-To: <20130106005053.GS16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 01:50 +0100, Willy Tarreau wrote:

> Yes, I've removed all zero counters in this short view for easier
> reading (complete version appended at the end of this email). This
> was after around 140 GB were transferred :

OK I only wanted to make sure skb were not linearized in xmit.

Could you try to disable CONFIG_COMPACTION ?

( This is the other thread mentioning this : "ppoll() stuck on POLLIN
while TCP peer is sending" )
