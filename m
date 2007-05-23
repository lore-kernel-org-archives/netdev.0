From: =?ISO-8859-1?Q?=22Thomas_B=2E_R=FCcker=22?= <dm8tbr@openpma.org>
Subject: Re: UDP checksum broken since 2.6.18?
Date: Wed, 23 May 2007 10:33:16 +0000
Message-ID: <4654186C.8050505@openpma.org>
References: <E1Hqnea-0006Af-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, pg@futureware.at,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn-da.werderstrasse.de ([217.195.43.101]:48239 "EHLO
	dk0td.afthd.tu-darmstadt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757677AbXEWKdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 06:33:19 -0400
In-Reply-To: <E1Hqnea-0006Af-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> "Thomas B. R??cker" <dm8tbr@openpma.org> wrote:
>   
>> Stephen Hemminger wrote:
>>     
>>> The packet passed to packet capture programs may not have a valid checksum
>>> if you have checksum offload configured on the device.  What kind of hardware
>>> do you have on sender and receiver? 
>>>       
>> The c-snippet uses 127.x.x.x --> loopback
>>     
>
> We never compute the complete checksum for loopback so that explains
> the bogus checksum.
>   
Does this also explain why wireshark thinks the checksum is right when
tested on <=2.6.17?

Cheers

Thomas
