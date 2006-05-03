From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 14:11:06 +0100
Message-ID: <4458ABEA.8040000@corky.net>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au> <4458A6C1.90103@corky.net> <20060503115653.GA1353@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:25054 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965174AbWECMMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 08:12:10 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060503115653.GA1353@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi
> On Wed, May 03, 2006 at 01:49:05PM +0100, Just Marc wrote:
>   
>> You're right, actually this box serves http/ftp file transfers only, 
>> it's a mirror with a large amount of downloads a day.
>>     
>
> That's interesting.  The RX bug that I fixed earlier would usually
> manifest itself under exactly these conditions.  Alas you're running
> a fixed kernel.
>
>   
>> I gave it another look, many of the prints are repeat prints for the 
>> same remote IPs,
>>     
>
> Can you take a tcpdump of the TCP sessions involving those IPs and
> then show me the sections that occur when those messages are triggered?
>
>   
OK, I'll try that.
>> I agree, however, I think it's pretty good to allow an admin to toggle 
>> it off completely.  Maybe that's all we need, really.
>>     
>
> The question is always what you want to be off and what to leave on.
> After all, you can turn off all printk's to the console through /proc.
> If you also tell klogd to ignore them then you won't see anything at
> all (unless you run dmesg).
>   
The problem is that it's really BAD to suppress all messages, there may 
be critical ones.  In my opinion while the treason uncloaked message can 
help uncover bugs it is mostly redundant on a day to day usage for 
probably 99% of the scenarios.

Marc
