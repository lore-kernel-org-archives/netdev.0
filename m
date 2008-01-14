From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: Re: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Mon, 14 Jan 2008 13:40:00 -0200
Message-ID: <478B8250.90602@bspu.unibel.by>
References: <47866C69.3080904@bspu.unibel.by>	 <1200001167.4443.38.camel@localhost>  <4787A663.4030204@bspu.unibel.by>	 <1200063541.4483.42.camel@localhost>  <4787D49E.6080906@bspu.unibel.by>	 <1200107027.4477.36.camel@localhost>  <4788FF45.702@bspu.unibel.by> <1200253484.4427.33.camel@localhost>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, mahatma@eu.by
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:40262 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753AbYANLlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 06:41:42 -0500
In-Reply-To: <1200253484.4427.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:

>> I in doubts only about "action continue".
>> To "and/or" behaviour one of best usage are (example):
> 
> I dont think you should be touching the action part at all primarily
> because actions can set the mark after classification. 

Yes, I only do it by inertia after "#define tc_index mark".

I not understand why "tc_index" changed in this place. 1) there are ingress 2) 
there are "OK" action. Are "tc_index" will not changed after: "tc filter add 
dev eth0 parent ffff: ... flowid 1:1 action continue" ? In general - are 
tc_index useful in ingress? (may be tc_index used in [nf]mark-style, but even 
in netfilter it feature migrate - IMHO, may be I time to time do not see in 
needed place)

Sorry, I just change focus from existing "tc_index=..." to common behaviour ;)

[...]
> Please refer to what i said above; if what i said still doesnt make
> sense i can create (the simple) patch.

A bit vague... sorry...

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
