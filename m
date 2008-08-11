From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 19:44:42 -0400
Message-ID: <48A0CEEA.9080104@hp.com>
References: <20080809213101.0927a808.akpm@linux-foundation.org>	<489F8827.4030904@hp.com>	<82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com> <20080811.143212.172434871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: parag.warudkar@gmail.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:1545 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbYHKXop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 19:44:45 -0400
In-Reply-To: <20080811.143212.172434871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Parag Warudkar" <parag.warudkar@gmail.com>
> Date: Sun, 10 Aug 2008 21:05:07 -0400
> 
>> On Sun, Aug 10, 2008 at 8:30 PM, Brian Haley <brian.haley@hp.com> wrote:
>>
>>> John sent me email off-line saying the patch fixed the problem, but he'd do
>>> more testing over the weekend.
>> I did test the patch and it now spits out "EOF on netlink" like
>> mentioned in bugzilla, which is not consistent with earlier behavior
>> which was to output -
>> unreachable fec0::1 dev lo  table unspec  proto none  src ::1  metric
>> -1  error -101 hoplimit 255 .
> 
> We need to resolve this, Brian?

I don't see "EOF on netlink" on 2.6.27-rc2.  I can dig-up a 2.6.24 
kernel, I'm just wondering if that EOF happens when the IPv6 module 
isn't loaded or something?

-Brian
