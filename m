From: John Haxby <john.haxby@oracle.com>
Subject: Re: [PATCH 1/2] netfilter: xtables: inclusion of xt_SYSRQ
Date: Wed, 28 Apr 2010 16:50:16 +0100
Message-ID: <4BD85938.104@oracle.com>
References: <1271845618-28569-1-git-send-email-jengelh@medozas.de> <1271845618-28569-2-git-send-email-jengelh@medozas.de> <4BCEF6B4.8090105@trash.net> <alpine.LSU.2.01.1004211506280.10840@obet.zrqbmnf.qr> <4BCEFACC.7020804@trash.net> <alpine.LSU.2.01.1004211533410.21020@obet.zrqbmnf.qr> <4BD84992.5030909@oracle.com> <4BD84C23.2000301@oracle.com> <alpine.LSU.2.01.1004281701220.9518@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004281701220.9518@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/04/10 16:03, Jan Engelhardt wrote:
> On Wednesday 2010-04-28 16:54, John Haxby wrote:
>    
>> use-case I see -- the one I see is where the sys admins used to have a "crash
>> trolley" which was a console and PS/2 keyboard which they could plug into a
>> machine to get some information, but as many rack machines no longer have
>> anything PS/2 and USB hot plug is unlikely to work on a sick machine
>>      
> Oh I can tell you stories... sometimes it's so dead in the water that
> the console unblanking would not work any more, rendering even any PS/2
> useless. Stupid southbridge chipsets blowing up DMA :-)
>    

There's no hope in that case :-)  Just take the machine out and give it 
a decent burial.

On the other hand it's not uncommon to see reports that a machine has 
"hung totally" that include output from ping to show that it hasn't.  
Actually it's amazingly common to see this.  And in just this situation 
xt_SYSRQ is still quite likely to work.

jch
