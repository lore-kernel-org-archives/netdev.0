From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 14:08:39 +0100
Message-ID: <4458AB57.6060706@corky.net>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <200605031347.31281.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:28381 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965165AbWECMJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:09:46 -0400
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200605031347.31281.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
> Herbert Xu wrote:
>   
>> BTW, this message is already under net_ratelimit so I don't see any
>> urgency in getting rid of it completely.  If we're going down the
>> path of disabling it, we probably should go for something more global
>> rather than a sysctl that controls this one message.
>>     
>
> Already there: /proc/sys/net/core/{message_cost,message_burst}
>
> Just set burst to 0 and cost to a very big value to basically supppress
> all net_ratelimit()ed messages.
>
> Or did you think of sth. else?
>   
That's good, but it may (and probably will) suppress many other messages 
which may be of more interest...

Marc
