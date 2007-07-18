From: =?ISO-8859-15?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
Subject: Re: pmtu discovery on SA
Date: Wed, 18 Jul 2007 19:56:58 +0300
Message-ID: <469E465A.9000902@kolumbus.fi>
References: <469A3698.5020105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323022E@exch.facton.local> <3C59DB883F7B0B4D8096010D45ACCD1323023A@exch.facton.local> <469B7001.3090604@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323023D@exch.facton.local> <469B7B99.6040402@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230240@exch.facton.local> <469B878C.1020204@trash.net> <469B8C47.3030306@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230242@exch.facton.local> <469BB50C.10203@trash.net> <469CE9E5.7040003@trash.net> <3C59DB883F7B0B4D8096010D45ACCD1323024F@exch.facton.local> <469D3885.7070208@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230254@exch.facton.local> <469E1242.3050105@trash.net> <3C59DB883F7B0B4D8096010D45ACCD13230257@exch.facton.local> <469E3F6F.6040004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Beschorner Daniel <Daniel.Beschorner@facton.com>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:47610 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760802AbXGRSJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 14:09:52 -0400
In-Reply-To: <469E3F6F.6040004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Beschorner Daniel wrote:
>   
>>> Beschorner Daniel wrote:
>>>
>>> So its using 1492 now? Otherwise it would be expected since the
>>> initial MTU calculation would be based on 1500.
>>>       
>> I'm using 1500 again.
>>
>> Just to make it clear: Is this message an error, or a warning or just
>> for information?
>> Could you explain a bit please.
>>     
>
>
> Its a debugging message nowadays (NETDEBUG). I was mostly interested
> in this since I changed the IPsec MTU calculation in 2.6.22 and it
> might have been a bug.
>
>   
And we don't have pmtu discovery for esp yet, right?

--Mika

