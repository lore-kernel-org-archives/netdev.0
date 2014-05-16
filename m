From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 08:26:11 -0700
Message-ID: <1400253971.7973.186.camel@edumazet-glaptop2.roam.corp.google.com>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
	 <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53761286.2040505@candelatech.com>
	 <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516145032.GD8346@casper.infradead.org>
	 <1400252935.7973.176.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516152035.GE8346@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:55867 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932283AbaEPP0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:26:13 -0400
Received: by mail-pa0-f45.google.com with SMTP id ey11so2697607pad.4
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 08:26:13 -0700 (PDT)
In-Reply-To: <20140516152035.GE8346@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 16:20 +0100, Thomas Graf wrote:

> I'm aware of the work and I agree. That is perfectly fine if the
> produced skbs do not get enqueued and modified. Otherwise the clone
> and COW will undo the gain again. I need pktgen to produce large,
> linear skbs with a unique flow for each individual packet. Hence this
> optimization ;-)

pktgen is a tool for us kernel net developers.

I doubt more than 20 people on this planet used it in the last 12
months, expecting crazy numbers out of one core, while a simple user
space program can outperform pktgen these days.

So if you need a very specific hack, you can do it on your local tree ;)
