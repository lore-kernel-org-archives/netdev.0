From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clean up sparse cast warning in do_ip_getsockopt
Date: Mon, 21 Jul 2014 14:31:46 -0700 (PDT)
Message-ID: <20140721.143146.680791642503413523.davem@davemloft.net>
References: <20140720113017.GA8878@gmail.com>
	<20140720.222246.722922848026554870.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D17279EB0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: karoly.kemeny@gmail.com, jmorris@namei.org, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753514AbaGUVbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 17:31:48 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17279EB0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Mon, 21 Jul 2014 08:54:02 +0000

> From: David Miller
>> From: Karoly Kemeny <karoly.kemeny@gmail.com>
>> Date: Sun, 20 Jul 2014 13:30:17 +0200
>> 
>> > There is a sparse warning because of the implicit pointer cast in
>> > do_ip_getsockopt.
>> >
>> > Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
>> 
>> Please format your subject line correctly, it should be of the form:
>> 
>> 	[PATCH] ${SUBSYSTEM}: Description.
>> 
>> Your's is missing the subsystem prefix, which in this case should
>> be "ipv4: "
>> 
>> > -		msg.msg_control = optval;
>> > +		msg.msg_control = (__force void*) optval;
>> 
>> Please put a space between "void" and "*" in the cast.
> 
> And remove the one after the ')' ?

Not necessarily, I don't like when the closing parens and the variable
"touch".
