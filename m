From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Mon, 14 Jan 2008 20:20:17 -0200
Message-ID: <478BE021.1070408@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by>	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by>	 <1200253484.4427.33.camel@localhost>  <478B8250.90602@bspu.unibel.by> <1200315372.4427.75.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:53356 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbYANSU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:20:28 -0500
In-Reply-To: <1200315372.4427.75.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:

May be I am mix in mind other code (multi-class loop/walking) and this code. I 
am deprogramming... ;)

>> Sorry, I just change focus from existing "tc_index=..." to common behaviour ;)
> 
>> [...]
>>> Please refer to what i said above; if what i said still doesnt make
>>> sense i can create (the simple) patch.
>> A bit vague... sorry...
> 
> I mean:
> 
> #ifdef CONFIG_NET_CLS_ACT
> .... leave this part alone which already sets tc_index ...
> #else
> ...set tc_index and mark here ...
> #endif
> 
> And when we have a metadata action - we remove setting of tc_index from
> #ifdef CONFIG_NET_CLS_ACT
> 
> Did that make sense?

After current "#endif" - may be.

What "result" are with:
1) no filters?
2) 1 filter only, with "action continue"?

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
