From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Thu, 18 Dec 2014 18:44:35 +0100
Message-ID: <54931283.1030804@users.sourceforge.net>
References: <548B1E44.6050005@users.sourceforge.net>	<20141212.115922.687789059853236747.davem@davemloft.net>	<54930D7C.3000901@users.sourceforge.net> <20141218.122556.2148647081075440879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:65292 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbaLRRon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 12:44:43 -0500
In-Reply-To: <20141218.122556.2148647081075440879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Now I find still that your data reorgansisation wish can not be resolved
>> in a simple way.
> 
> I'm saying to leave the code alone.

It seems that there might be a misunderstanding between us.


> If it goes:
> 
> 	var = foo_that_returns_ptr_err()
> 	if (IS_ERR(var))
> 		return PTR_ERR(var);
> 
> 	p->bar = var;
> 
> or whatever, simply keep it that way!

A simple return was not used by the mppe_alloc() function so far because
a bit of memory clean-up will also be useful after error detection,
won't it?


> I'm not engaging in this conversation any further, you have already
> consumed way too much of my limited time on this incredibly trivial matter.

It can occasionally happen that a safe clarification of specific implementation
details will need more efforts than you would like to invest at the moment.

Regards,
Markus
