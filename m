From: David Miller <davem@davemloft.net>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Mon, 28 Jul 2014 17:19:00 -0700 (PDT)
Message-ID: <20140728.171900.1527499085392907198.davem@davemloft.net>
References: <1406326508.13203.10.camel@localhost>
	<CAPAsAGwc7B2rB+3wTHkL97B5eDchbcuhfkKef56ARCy2CxCGuQ@mail.gmail.com>
	<1406390080.22881.75.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ryabinin.a.a@gmail.com, a.ryabinin@samsung.com,
	sasha.levin@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com, edumazet@google.com
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406390080.22881.75.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 26 Jul 2014 17:54:40 +0200

> On Sa, 2014-07-26 at 19:48 +0400, Andrey Ryabinin wrote:
>> 2014-07-26 2:15 GMT+04:00 Hannes Frederic Sowa <hannes@stressinduktion.org>:
>> > Otherwise I would just set msg_namelen = 0, too, and just not handle
>> > passed in NULL pointers to sockaddrs.
>> >
>> 
>> I like that, how about such chage:
 ...
> LGTM! Can you send a patch?

I definitely agree that we should treat NULL as no address specified.
