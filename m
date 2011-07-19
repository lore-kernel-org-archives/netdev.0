From: Matt Evans <matt@ozlabs.org>
Subject: Re: [PATCH] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 11:21:28 +1000
Message-ID: <4E24DC18.7050007@ozlabs.org>
References: <4E23E5C3.1070209@ozlabs.org>	<1310978375.5756.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20110718.124248.1462465498024218250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47823 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab1GSBU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 21:20:59 -0400
In-Reply-To: <20110718.124248.1462465498024218250.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/11 05:42, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 18 Jul 2011 10:39:35 +0200
> 
>> So in PPC SEEN_XREG only is to be set of X is read, not if written.
>>
>> So you dont have to set SEEN_XREG bit in this part :
> 
> Matt, do you want to integrate changes based upon Eric's feedback
> here or do you want me to apply your patch as-is for now?

Thanks, but no worries; I will send a v2 in a sec.  Eric's comments are spot-on,
and there are a couple of other areas that the brainfart should really be
polished out of, too.  :-)


Cheers,


Matt
