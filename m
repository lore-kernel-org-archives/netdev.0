From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Thu, 10 Jul 2003 22:57:12 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0DC518.3010301@kolumbus.fi>
References: <20030710154302.GE1722@zip.com.au> <20030711.005542.04973601.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cat@zip.com.au, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   pekkas@netcore.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
 <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



But 3ffe:8001:000c:ffff::36 is _not_ subnet routers anycast address. Anyway, looks like a bug to me...


--Mika


YOSHIFUJI Hideaki / ???? wrote:

>In article <20030710154302.GE1722@zip.com.au> (at Fri, 11 Jul 2003 01:43:03 +1000), CaT <cat@zip.com.au> says:
>
>  
>
>>With 2.4.21-pre2 I can get a nice tunnel going over my ppp connection
>>and as such get ipv6 connectivity. I think went to 2.4.21 and then to
>>2.4.22-pre4 and bringing up the tunnel fails as follows:
>>    
>>
>:
>  
>
>>ip addr add 3ffe:8001:000c:ffff::37/127 dev sit1
>> ip route add ::/0 via 3ffe:8001:000c:ffff::36 
>>RTNETLINK answers: Invalid argument
>>    
>>
>
>This is not bug, but rather misconfiguration;
>you cannot use prefix::, which is mandatory subnet routers 
>anycast address, as unicast address.
>
>Thank you.
>
>  
>
