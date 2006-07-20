From: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 20 Jul 2006 11:42:30 +0400
Message-ID: <20060720074230.GA21258@tservice.net.ru>
References: <20060719110035.GA10081@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.178.208.66] ([195.178.208.66]:5870 "EHLO tservice.net.ru")
	by vger.kernel.org with ESMTP id S932567AbWGTHmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2006 03:42:31 -0400
To: Jrn Engel <joern@wohnheim.fh-wedel.de>
Content-Disposition: inline
In-Reply-To: <20060719110035.GA10081@wohnheim.fh-wedel.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

[ Sorry for long delay, there are some problems with mail servers, so I
can not access them remotely, so I create mail by hads, hopefully thread
will not be broken. ]

>> > Your description makes it sound as if you would take a huge leap,
>> > changing all in-kernel code _and_ the userspace interface in a
>> > single
>> > patch.  Am I wrong?  Or am I right and would it make sense to
>> > extract
>> > small incremental steps from your patch similar to those Van did in
>> > his non-published work?
>> 
>> My first implementation used existing kernel code and showed small
>> performance win - there was binding of the socket to netchannel and
>> all
>> protocol processing was moved into process context.

>Iirc, Van didn't show performance numbers but rather cpu utilization
>numbers.  And those went down significantly without changing the
>userspace interface.

At least lca presentation graphs shows exactly different numbers - 
performance without CPU utilization (but not as his tables).

>Did you look at cpu utilization as well?  If you did and your numbers
>are worse than Vans, he either did something smarter than you or
>forged his numbers (quite unlikely).

Interesting sentence from political correcteness point of view :)

I did both CPU and speed measurements when used socket code [1], 
and both of them showed small gain, but I only tested 1gbit setup, so
they can not be compared with Van's.
But even with 1gb I was not satisfied with them, so I started different
implementation, which I described in my e-mail to Alexey.

1. speed/cpu measurements of one of the netchannels implementation which
used socket code.
http://thread.gmane.org/gmane.linux.network/36609/focus=36614

-- 
	Evgeniy Polyakov
