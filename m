From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 08:33:23 -0700
Message-ID: <1395070403.9668.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317135101.GA8956@casper.infradead.org>
	 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6DF4C4@AcuExch.aculab.com>
	 <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317153016.GC8956@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:48588 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756619AbaCQPd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:33:28 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so5820588pab.22
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 08:33:27 -0700 (PDT)
In-Reply-To: <20140317153016.GC8956@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 15:30 +0000, Thomas Graf wrote:

> So why do we have reciprocal_divide()?

Thats when you do not have a constant divisor ;)

Gcc uses a reciprocal divide if the divisor is known/constant.

If not, it _has_ to use a real divide.
