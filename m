From: Patrick McHardy <kaber@trash.net>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Wed, 09 Jun 2010 17:16:56 +0200
Message-ID: <4C0FB068.9090700@trash.net>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com> <4C08EB85.3050900@trash.net> <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com> <4C0FA24A.7060907@trash.net> <alpine.LSU.2.01.1006091713260.30265@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36337 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705Ab0FIPQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 11:16:58 -0400
In-Reply-To: <alpine.LSU.2.01.1006091713260.30265@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Wednesday 2010-06-09 16:16, Patrick McHardy wrote:
>>>> You could use the NOTRACK target to bypass connection tracking.
>>>>         
>>> I tried the NOTRACK target, but the packet is still going
>>> throught reassembly, because the RAW filter has lower priority
>>> then the connection track defragmentation..
>>>       
>> Right.
>>     
>
> Blech. That reminds me of
> http://marc.info/?l=netfilter-devel&m=126581823826735&w=2
>   

We already fixed that.

