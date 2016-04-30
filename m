From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?B?ZG9u4oCZdCBtb2RpZnkgaXBf?=
 =?UTF-8?B?c3VtbWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3M=?=
 =?UTF-8?B?dW1zIGFzIGdvb2Qu?=
Date: Sat, 30 Apr 2016 12:40:07 -0700
Message-ID: <57250A17.5090804@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk>	 <5720E1F0.9010203@candelatech.com>	 <1461780469.5102.0.camel@decadent.org.uk>	 <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>	 <572155F4.10405@candelatech.com>	 <20160428102953.GA7656@bistromath.localdomain> <1462041181.17662.3.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	xiyou.wangcong@gmail.com
To: Ben Hutchings <ben@decadent.org.uk>,
	Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54628 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbcD3TkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 15:40:11 -0400
In-Reply-To: <1462041181.17662.3.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/30/2016 11:33 AM, Ben Hutchings wrote:
> On Thu, 2016-04-28 at 12:29 +0200, Sabrina Dubroca wrote:
>> Hello,

>>> http://dmz2.candelatech.com/?p=linux-4.4.dev.y/.git;a=commitdiff;h=8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=454b07405d694dad52e7f41af5816eed0190da8a
>> Actually, no, this is not really a regression.
> [...]
>
> It really is.  Even though the old behaviour was a bug (raw packets
> should not be changed), if there are real applications that depend on
> that then we have to keep those applications working somehow.

To be honest, I fail to see why the old behaviour is a bug when sending
raw packets from user-space.  If raw packets should not be changed, then
we need some way to specify what the checksum setting is to begin with,
otherwise, user-space has not enough control.

A socket option for new programs, and sysctl configurable defaults for raw sockets
for old binary programs would be sufficient I think.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
