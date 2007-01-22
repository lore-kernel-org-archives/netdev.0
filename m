From: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>
Subject: Re: adm8211 (from linville wireless-2.6) in xen guest
Date: Mon, 22 Jan 2007 22:56:11 +0100
Message-ID: <45B532FB.6080200@caiway.nl>
References: <45B208DA.8010807@caiway.nl> <200701221430.50547.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cardassian.kabelfoon.nl ([62.45.45.18]:55604 "EHLO
	cardassian.kabelfoon.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbXAVV4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 16:56:14 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200701221430.50547.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael,

Michael Wu wrote:
> On Saturday 20 January 2007 07:19, Jan Evert van Grootheest wrote:
>   
>> One question, though. I'm trying to use it in ad-hoc mode. If there's no
>> other station with the same essid, it just keeps mentioning that
>> (besides the BCNTC and TSFTF messages)
>>
>> wlan0: No matching adhoc sta found. Creating IBSS 00:04:e2:3f:2a:70 CHAN=11
>>
>> And the IBSS changes every time, which is about every 30 seconds. Is it
>> really supposed to change the IBSS each time?
>>     
> Probably not, but I never debugged adhoc mode enough.
>   
If there're some tests I can help with, just ask.
I've decided yesterday that I really should get myself a WRT54G or 
somesuch. So there's not much pressure for this adm8211 anymore.
>> The reason I ask is that my wife has a laptop with an Atheros chip in
>> it. If it is configured for ad-hoc it creates the IBSS and sticks with
>> it. So I now have two computers that have different behaviour in this
>> respect. That in itself is not, I guess, a problem. But it seems to me
>> that the random IBSS created by the adm8211 would result in two stations
>> not seeing eachother or taking longer than necessary to find eachother?
>>
>>     
> Have you checked? I think the bssid should stop changing once another station 
> with the same ssid comes into range.
>   
Well, it took more than 1 minute and I left for coffee. When I returned 
they had found eachother.

Do you perhaps know whether there's a sourcetree somewhere of the dscape 
code that can be compiled as external modules for 2.6.18?
At least I can help test the dscape code, which I understand is the 
current future of wireless in linux.

Thanks,
Jan Evert

