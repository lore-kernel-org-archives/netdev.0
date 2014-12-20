From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH v2 0/6] net-PPP: Deletion of a few unnecessary checks
Date: Sat, 20 Dec 2014 16:48:10 +0100
Message-ID: <54959A3A.4030104@gmx.de>
References: <548B1E44.6050005@users.sourceforge.net>	<20141212.115922.687789059853236747.davem@davemloft.net>	<54930D7C.3000901@users.sourceforge.net> <20141218.122556.2148647081075440879.davem@davemloft.net> <54958B8C.7010105@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <54958B8C.7010105@users.sourceforge.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On 20.12.2014 15:45, SF Markus Elfring wrote:
>> I'm saying to leave the code alone.
> 
> Do I need to try another interpretation out for your feedback?
> 
> 
>> If it goes:
>> 
>> 	var = foo_that_returns_ptr_err()
>> 	if (IS_ERR(var))
>> 		return PTR_ERR(var);
>> 
>> 	p->bar = var;
>> 
>> or whatever, simply keep it that way!
> 
> Do you want to express here that a data structure member should
> only be set after a previous function call succeeded?
> 

I think what David said was pretty clear: If you see code like the above
there is no need to refactor it. That does not mean that this is the
_preferred_ way of error handling. Its just good enough to be left alone.

Regards,
Lino
