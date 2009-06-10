From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from untrusted
 sources
Date: Tue, 09 Jun 2009 22:52:11 -0700
Message-ID: <4A2F4A0B.3020205@us.ibm.com>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com> <20090608051608.GA19748@gondor.apana.org.au> <200906101310.41094.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42765 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbZFJFwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 01:52:14 -0400
In-Reply-To: <200906101310.41094.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Mon, 8 Jun 2009 02:46:08 pm Herbert Xu wrote:
>   
>> On Fri, Jun 05, 2009 at 05:16:31PM -0700, Sridhar Samudrala wrote:
>>     
>>> +	/* Software UFO is not yet supported */
>>> +	segs = ERR_PTR(-EPROTONOSUPPORT);
>>>       
>> Hmm, we need to fill this in before you start using it for virt.
>> After all, it's very difficult for the guest to know whether the
>> output device on the host is going to be able to do UFO or not.
>>     
>
> Yep, no point telling the guest we support UFO if we don't!
>   
This path is taken only when the packet needs to go out a device that 
doesn't support UFO.
Until the software UFO is supported, I thought it may be useful to 
provide a way to enable
UFO inter-guest, between host to guest and to an external host via an 
outgoing device that supports UFO.

Thanks
Sridhar

