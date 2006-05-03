From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 14:25:25 +0100
Message-ID: <4458AF45.9050108@corky.net>
References: <E1FbGCo-0000OS-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@axxeo.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:40901 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965168AbWECM0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:26:32 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FbGCo-0000OS-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
> Just Marc <marc@corky.net> wrote:
>   
>>   
>> That's good, but it may (and probably will) suppress many other messages 
>> which may be of more interest...
>>     
>
> That's the crux of the matter.  There is no way we can satisfy everyone
> short of putting a knob on each individual printk.
>
> So the only solution is to do the filtering yourself in userspace through
> klogd/syslogd.
>   
It is the crux of the matter. This print is a purely informational one, 
absolutely harmless (unless I'm mistaken) and clogs kernel  logs 
throughout the universe :)

Seriously, other kernel prints are usually not so harmless and are 
generally more important to see.  Let me  put it another way, except 
this print, I have no other prints whatsoever on any of my machines and 
if there are prints, I usually do want to know about them, I learned to 
ignore this print over the years.   I believe many people are in the 
same boat.

That's my opinion, anyway.

Thanks
