From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 13:49:05 +0100
Message-ID: <4458A6C1.90103@corky.net>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:62156 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965157AbWECLuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 07:50:11 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
> Just Marc <marc@corky.net> wrote:
>   
>> We're now at 2.6.16.12 and it is still showing thousands of times a day 
>> on a busy web server, have all the bugs been discovered yet?
>>     
>
> There are no known bugs on the RX side in 2.6.16 that would cause this.
> The few busy web servers that I have access to do not see this message
> at all.
>
> So either your web server is somehow attracting a lot of buggy TCP stacks,
> or there could be a dodgy gateway in your path that is mucking with the
> TCP windows.
>
>   
You're right, actually this box serves http/ftp file transfers only, 
it's a mirror with a large amount of downloads a day.

On a pure html/image web server that is just as busy, there are only a 
few of these messages, one or two a day.
> I suggest that you do a tcpdump to see what it looks like.  It might turn
> out that we do still have a bug on our RX side.
>   
I gave it another look, many of the prints are repeat prints for the 
same remote IPs,
> BTW, this message is already under net_ratelimit so I don't see any
> urgency in getting rid of it completely.  If we're going down the
> path of disabling it, we probably should go for something more global
> rather than a sysctl that controls this one message.
>   
I agree, however, I think it's pretty good to allow an admin to toggle 
it off completely.  Maybe that's all we need, really.

Thanks
