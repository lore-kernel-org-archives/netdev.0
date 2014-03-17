From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 08:52:08 -0700
Message-ID: <1395071528.9668.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313211509.GP21124@linux.vnet.ibm.com> <53229704.1040808@gmail.com>
	 <20140314132834.GS21124@linux.vnet.ibm.com>
	 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317135101.GA8956@casper.infradead.org>
	 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6DF4C4@AcuExch.aculab.com>
	 <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6DF5AE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:48539 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbaCQPwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:52:12 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so5917570pad.3
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 08:52:11 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6DF5AE@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 15:43 +0000, David Laight wrote:

> The nios cpu on my fpga can't :-)

In this case, gcc will use a reciprocal divide.

Depending on the divisor it can be one or two multiply, and some
trivial arithmetics.
