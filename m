From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Wed, 9 Jun 2010 17:20:37 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006091719010.30265@obet.zrqbmnf.qr>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com> <4C08EB85.3050900@trash.net> <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com> <4C0FA24A.7060907@trash.net> <alpine.LSU.2.01.1006091713260.30265@obet.zrqbmnf.qr>
 <4C0FB068.9090700@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C0FB068.9090700@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2010-06-09 17:16, Patrick McHardy wrote:
>Jan Engelhardt wrote:
>> On Wednesday 2010-06-09 16:16, Patrick McHardy wrote:
>>>>> You could use the NOTRACK target to bypass connection tracking.
>>>>>         
>>>> I tried the NOTRACK target, but the packet is still going
>>>> throught reassembly, because the RAW filter has lower priority
>>>> then the connection track defragmentation..
>>>
>>> Right.
>>
>> Blech. That reminds me of
>> http://marc.info/?l=netfilter-devel&m=126581823826735&w=2
>
>We already fixed that.

I know, and I posted it for the understanding of the OP
as to why RAW is after DEFRAG.
