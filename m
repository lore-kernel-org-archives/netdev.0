From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Regression associated with commit c8628155ece3 - "tcp: reduce
 out_of_order memory use"
Date: Mon, 10 Sep 2012 09:53:51 -0500
Message-ID: <504DFEFF.6060004@lwfinger.net>
References: <50369925.3050705@lwfinger.net>  <1345757200.5904.1890.camel@edumazet-glaptop> <50378B35.80307@lwfinger.net>  <20120824.111948.680531915905273128.davem@davemloft.net>  <5037A4B0.3080208@lwfinger.net>  <1345825095.19483.19.camel@edumazet-glaptop>  <1345825432.19483.20.camel@edumazet-glaptop> <5037B2AC.50704@lwfinger.net>  <1345830424.19483.69.camel@edumazet-glaptop>  <503BB49C.5010402@lwfinger.net> <1347266366.1234.1267.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40714 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab2IJOxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:53:55 -0400
In-Reply-To: <1347266366.1234.1267.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2012 03:39 AM, Eric Dumazet wrote:
> On Mon, 2012-08-27 at 12:55 -0500, Larry Finger wrote:
>
>> I have prepared a patch to fix all the unchecked allocations.
>>
>> Over the weekend I made some progress. To test the latest vendor driver, I
>> installed a 32-bit system. Their driver is not compatible with a 64-bit system.
>> I found that not only did the vendor driver work with secure sites, but so did
>> the in-kernel version. I now have tcpdump output for the 32-bit case that works,
>> and the 64-bit case that fails. It seems likely that I missed some 32/64 bit
>> incompatibility when I did the conversion.
>>
>> Thanks for all your help in trying to resolve this issue.
>>
>> Larry
>>
>>
>
> Hi Larry
>
> It appears I have a D-Link N300 (DWA-131) nano USB adapter, using
> staging/rtl8712 driver.
>
> I tried many kernel versions (including 3.3) and none seems to work
> reliably.
>
> Sometime, I have some traffic but only for about 50 frames...
> It might be because my access point is a netgear wndr3800, because I
> have following warning a bit before the freezes :
>
> r8712u: [r8712_got_addbareq_event_callback] mac = 20:4e:7f:5a:cd:30, sea = 80, tid = 0

Eric,

What is the md5sum for the firmware file /lib/firmware/rtlwifi/rtl8712u.bin? 
Over the weekend, there was a report of another device that had problems with 
firmware that was added to the linux-firmware repo in July with md5sum of 
c6f3b7b880aefb7b3f249428d659bdbb. An older version with md5sum of 
200fd952db3cc9259b1fd05e3e51966f works in that case. I'll send you this one 
privately.

I have a Netgear WNDR3300 and also get the addbareq events, but I do not get 
freezes. I'm not sure the message is correlated.

Larry
