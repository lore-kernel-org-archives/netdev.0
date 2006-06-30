From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 16:54:44 -0400
Message-ID: <1151700884.5270.278.camel@jzny2>
References: <44A5606B.5080003@trash.net> <1151697554.5270.241.camel@jzny2>
	 <20060630203034.GN14627@postel.suug.ch>
	 <20060630.133348.68039806.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:14754 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932369AbWF3Uyr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 16:54:47 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwQ0p-0007zF-RG
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 16:54:51 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060630.133348.68039806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 13:33 -0700, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Fri, 30 Jun 2006 22:30:34 +0200
> 
> > Lack of stylistic commas is less of a concern, rather the lack of
> > comments and notes where absolutely essential.
> 
> Yes, intent is very important to document when it is not
> obvious.
> 

I agree - and i try hard to document but at times there's too much
and a line needs to be drawn.
As an example:
the eth->ifb->ifb case though is a very corner case. All the IMQ types
need to only redirect to one ifb; while i test it ive always seen the
test as more of a boundary check than a useful setup.

And Thomas: I do keep notebooks ;-> I doodle about everything, they dont
all fit in my knapsack anymore so sometimes when i say i will go and
refer to my notes, it is real.

cheers,
jamal

