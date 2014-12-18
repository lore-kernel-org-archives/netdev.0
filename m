From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Thu, 18 Dec 2014 12:25:56 -0500 (EST)
Message-ID: <20141218.122556.2148647081075440879.davem@davemloft.net>
References: <548B1E44.6050005@users.sourceforge.net>
	<20141212.115922.687789059853236747.davem@davemloft.net>
	<54930D7C.3000901@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, paulus@samba.org,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54930D7C.3000901@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 18 Dec 2014 18:23:08 +0100

>>> Where should "the error pointers" be stored instead?
>> 
>> A local variable, before you assign it into the datastructure.
> 
> I have looked at the affected software infrastructure once more.
> Now I find still that your data reorgansisation wish can not be resolved
> in a simple way.

I'm saying to leave the code alone.

If it goes:

	var = foo_that_returns_ptr_err()
	if (IS_ERR(var))
		return PTR_ERR(var);

	p->bar = var;

or whatever, simply keep it that way!

I'm not engaging in this conversation any further, you have already
consumed way too much of my limited time on this incredibly trivial
matter.
