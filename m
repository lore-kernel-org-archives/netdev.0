From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] asix: silence log message from oversize packet
Date: Fri, 18 Dec 2015 21:25:14 -0500 (EST)
Message-ID: <20151218.212514.1288582729750012735.davem@davemloft.net>
References: <20151217175116.234fa63b@xeon-e3>
	<20151218.160853.1076037989795474904.davem@davemloft.net>
	<20151218161503.123b5171@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.hutchings@codethink.co.uk, ivecera@redhat.com,
	linuxbrad@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbbLSCZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 21:25:19 -0500
In-Reply-To: <20151218161503.123b5171@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 18 Dec 2015 16:15:03 -0800

> On Fri, 18 Dec 2015 16:08:53 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Thu, 17 Dec 2015 17:51:16 -0800
>> 
>> > Since it is possible for an external system to send oversize packets
>> > at anytime, it is best for driver not to print a message and spam
>> > the log (potential external DoS).
>> > 
>> > Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=109471
>> > 
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> 
>> Seems reasonable, applied, thanks Stephen.
> 
> It doesn't fix the bug that is generating the oversize packet, that still needs
> to be root caused.

Remote systems can do this easily.  It's not a bug in the driver.

Say you decrease the MTU to 500 or whatever, nothing in the hardware
prevents reception of > 500 byte frames.

It's only a software limit.
