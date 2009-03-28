From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: niu driver - Transmit timed out - 2.6.29
Date: Sat, 28 Mar 2009 08:25:41 +0100
Message-ID: <49CDD0F5.1060802@krogh.cc>
References: <49CB78A4.3020406@krogh.cc> <49CD2996.60502@krogh.cc> <49CD7266.1070002@sun.com> <49CDBE42.8030708@krogh.cc> <49CDC136.60709@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:34726 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752327AbZC1HZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2009 03:25:52 -0400
In-Reply-To: <49CDC136.60709@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote:
> Jesper Krogh wrote:
>> Matheos Worku wrote:
>>>> This is probably the interesting part:
>>>> Mar 26 13:25:49 hest kernel: [25335.587191] niu 0000:84:00.0: niu: 
>>>> eth4: bits (40000000) of register RXDMA_CFIG1 would not clear, 
>>>> val[c0000000]
>>> Jesper,
>>>
>>> One of the RX  ring DMAs  is failing to reset. I guess whatever is 
>>> hanging the TX side is affecting the RX side as well. Can you do 
>>> lspci on the function  and its siblings?
>>
>> Like this(please guide me if that wasn't the correct lspci output):
> 
> Jesper,
> 
> I was wondering if you can get the register dump just after the NIC hangs.
> 
> lspci -vvv -xxx -s 84:0

I will try to do that, but it involves more or less "putting a known bad 
driver" in production. And wait X days. (where X usually is less than 7 
and more than 2). So if there is more debugging code that would be 
helpful to have in the driver/kernel then it would be preferrable to get 
it in at the same time, in order to reduce the amount of trial-and-error 
cycles.

-- 
Jesper

