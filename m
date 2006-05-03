From: Just Marc <marc@corky.net>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 03 May 2006 05:44:48 +0100
Message-ID: <44583540.1030608@corky.net>
References: <44578691.4020402@corky.net> <200605021802.43301.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:64953 "EHLO zebday.corky.net")
	by vger.kernel.org with ESMTP id S964980AbWECDpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 23:45:49 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200605021802.43301.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Tuesday 02 May 2006 18:19, Just Marc wrote:
>
>   
>> I thought that maybe it's time to either set TCP_DEBUG to 0 or 
>> alternatively allow an admin to toggle the printing of this message 
>> off/on?  On a few busy web servers running usually latest versions of 
>> 2.6 I have this message displaying hundreds (if not more) times a day, 
>>     
>
> You're talking to a lot of broken TCP clients then.
>
>   
I don't think that's a surprise, with hundreds of thousands of visitors, 
thousands are probably broken.
>> completely clogging the kernel log and making it harder to see if there 
>> are more interesting messages being printed.   TCP_DEBUG is being used 
>> in one more place that may also not require it anymore and or have it 
>> always enabled.
>>     
>
> It's better to use run time switches for these kind of things.
>
>   
Agreed.
>> So, is it time to disable this print altogether? Is it time to allow an 
>> admin to toggle printing of this thing off?
>>     
>
> If it's disabled there should be probably a netstat counter for the condition instead.
>
>   
Yes, that would be better.
> It might be a reasonable simple beginner project for someone:
>
> - Convert all NETDEBUGs/TCP_DEBUG to a single netdebug sysctl
> - Then perhaps make a CONFIG to change its default: 0 or 1
> - Add statistics counters for all of these conditions
>   
It's indeed pretty simple, unfortunately I don't have the time to do 
it.  For myself, I'll just comment it out for now.   But clearly 
something needs to be done about this one.

Thanks

