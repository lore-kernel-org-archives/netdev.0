From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 4 Dec 2014 10:53:49 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1412041052310.3861@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com> <547D37CA.7050506@audiocodes.com> <alpine.LNX.2.03.1412020729470.1351@gmail.com> <547D5F84.6020608@audiocodes.com> <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com> <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com> <547D7243.80508@audiocodes.com> <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no> <alpine.LNX.2.03.1412021453340.7488@gmail.com> <1417532733483.89987@audiocodes.com> <alpine.LNX.2.03.1412021627360.8131@gmail.com> <547EA1D1.8010202@audiocodes.com> <alpine.LNX.2.03.1412030659001.1288@gmail.com>
 <547EA82F.5050500@audiocodes.com> <alpine.LNX.2.03.1412040730480.1320@gmail.com> <548020DD.3030705@audiocodes.com> <874mtbojqo.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-879334618-1417686830=:3861"
Cc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux@gmail.com" <youtux@gmail.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:51138 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049AbaLDJxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 04:53:17 -0500
In-Reply-To: <874mtbojqo.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-879334618-1417686830=:3861
Content-Type: TEXT/PLAIN; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8BIT

Guys!
Don't forget I can test it - since I have a remote machine with 3.16 kernel 
and the device, at least for now.
So - Bjorn: do I need just to disable padding or do I need also to perform some 
other changes? I am sorry if I ask this a little bit stupidly, but I was 
alittle bit busy here.





On Thu, 4 Dec 2014, Bjørn Mork wrote:

> Date: Thu, 4 Dec 2014 10:19:11
> From: Bjørn Mork <bjorn@mork.no>
> To: Kevin Zhu <Mingying.Zhu@audiocodes.com>
> Cc: Enrico Mioso <mrkiko.rs@gmail.com>,
>     Eli Britstein <Eli.Britstein@audiocodes.com>,
>     Alex Strizhevsky <alexxst@gmail.com>,
>     Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
>     "youtux@gmail.com" <youtux@gmail.com>,
>     "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
>     "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Subject: Re: Is this 32-bit NCM?y
> 
> Kevin Zhu <Mingying.Zhu@audiocodes.com> writes:
>
>> Guys,
>>
>> After rearranging the padding, putting NCM0 right after NTH, and disable
>> ARP (FLAG_NOARP) and handling the offset alignment issue, it seems it
>> begins to work, though there's still problem with DHCP.
>
> Great!  But it would be good to know if _one_ of these changes is enough
> to make it work.
>
>> The DHCP packet's size becomes a large one after the TX function, which
>> is 16384, the maximum.
>
> You can now (from v3.16) disable the padding by setting min_tx_pkt >= tx_max.
> Something like this should do for a simple test:
>
> echo 16384 >/sys/class/net/wwan0/cdc_ncm/min_tx_pkt
>
>
> Bjørn
>
--8323328-879334618-1417686830=:3861--
