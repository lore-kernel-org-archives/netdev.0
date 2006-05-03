From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 09:06:30 +0100
Message-ID: <44586486.70702@corky.net>
References: <44578691.4020402@corky.net>	<200605021802.43301.ak@suse.de> <20060502.233246.92272407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:56524 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S965118AbWECHHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 03:07:31 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060502.233246.92272407.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Andi Kleen <ak@suse.de>
> Date: Tue, 2 May 2006 18:02:43 +0200
>
>   
>> On Tuesday 02 May 2006 18:19, Just Marc wrote:
>>
>>     
>>> I thought that maybe it's time to either set TCP_DEBUG to 0 or 
>>> alternatively allow an admin to toggle the printing of this message 
>>> off/on?  On a few busy web servers running usually latest versions of 
>>> 2.6 I have this message displaying hundreds (if not more) times a day, 
>>>       
>> You're talking to a lot of broken TCP clients then.
>>     
>
> Herbert Xu also fixed a bug that would cause that message
> to be emitted erroneously, 9 times out of 10 that is why
> people are seeing these messages.
>
> I think disabling that message is a non-starter, we want to
> see the message because as we've seen it can point to bugs
> on our end too.
>
>   
Correct, I noticed this was applied to 2.6.14, however, I am running 
2.6.16 (and now 2.6.16.12) on all of the machines in question, I am 
seeing hundreds of these messages a day...

Thanks

