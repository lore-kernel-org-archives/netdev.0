From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 23:35:12 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903182334410.30559@fbirervta.pbzchgretzou.qr>
References: <alpine.LSU.2.00.0902241125020.329@fbirervta.pbzchgretzou.qr> <20090318151216.60cd0363@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:52644 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbZCRWfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 18:35:14 -0400
In-Reply-To: <20090318151216.60cd0363@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2009-03-18 23:12, Stephen Hemminger wrote:
>On Tue, 24 Feb 2009 11:27:52 +0100 (CET)
>Jan Engelhardt <jengelh@medozas.de> wrote:
>
>> $ ip -6 r
>> fc00::/7 dev rtl0  proto kernel  metric 256  mtu 1500 advmss 1440 
>> hoplimit 4294967295
>> 
>> Most likely, "hoplimit -1" would be the right number, though I am not 
>> sure if simply changing %u by %d is a correct thing to do, since it 
>> would affect all fields.
>> 
>> ---
>>  ip/iproute.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>  	if (i != RTAX_RTT && i != RTAX_RTTVAR &&
>>  	    i != RTAX_RTO_MIN)
>> -		fprintf(fp, " %u", *(unsigned*)RTA_DATA(mxrta[i]));
>> +		fprintf(fp, " %d", *(unsigned*)RTA_DATA(mxrta[i]));
>
>No fix the kernel please.
>
And what should the kernel return?
