From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 12:39:50 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0E85E6.7050001@kolumbus.fi>
References: <20030711.143926.599349332.yoshfuji@linux-ipv6.org>	<Pine.LNX.4.44.0307111143470.26262-100000@netcore.fi> <20030711.180449.126456521.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, mika.liljeberg@welho.com, andre@tomt.net,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Who adds the subnet router anycast address, kernel itself? Since what? I 
don't see this in 2.5.

--Mika


YOSHIFUJI Hideaki / ???? wrote:

>In article <Pine.LNX.4.44.0307111143470.26262-100000@netcore.fi> (at Fri, 11 Jul 2003 11:46:00 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
>
>  
>
>>>I don't like this
>>>while I would be ok to have configuration option
>>>not to support anycast.
>>>      
>>>
>>With "not to support anycast" you probably meant "not to support
>>subnet-router anycast address [automatically, in the kernel, as now]" ?  
>>These are entirely different things.
>>    
>>
>
>I meant disabling anycast entirely.
>
>  
>
>>(Note that if there's a user-level API for setting anycast addresses, one 
>>could kick the subnet-router anycast address out of the kernel too.  
>>Whether that's desirable is another thing.)
>>    
>>
>
>We have but we cannot; it is refcnt'ed.
>
>--yoshfuji
>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>
