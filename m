From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Sat, 07 Nov 2009 15:28:31 -0800
Message-ID: <4AF6029F.6020403@hp.com>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>	<469958e00911061112y4d2d746cq93d90abfd6df7ec1@mail.gmail.com>	<1257535875.2610.15.camel@ppwaskie-mobl2> <20091107144938.82957125.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:12786 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753652AbZKGX23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2009 18:28:29 -0500
In-Reply-To: <20091107144938.82957125.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> On Fri, 06 Nov 2009, Peter P Waskiewicz Jr wrote:
> 
> 
>>On Fri, 2009-11-06 at 11:12 -0800, Caitlin Bestler wrote:
>>
>>>The approach you are proposing assumes what type of packet filters
>>>that L2 hardware could support.
>>>
>>>Why not simply use existing filtering rules that overshoot the target,
>>>such as netfilter, and ask the
>>>device specific tool to indicate what set of these rules it can support?
>>
>>Are you proposing that netfilter is modified to pass the filters down to
>>the hardware if it supports it?  netfilter doesn't steer flows though to
>>queues (or flow ID's in the kernel), plus that's putting HW-specific
>>capabilities into netfilter.  I'm not sure we want to do that.
>>
>>Please correct me if I'm wrong with interpreting your suggestion.
> 
> 
> Plus I believe using netfilter has a significant performance penalty,
> and it would be desirable to use such a feature without incurring
> this penalty when there was otherwise no need to use netfilter.

At the risk of typing words into someone's keyboard, I interpreted it as 
suggesting using the filtering language of netfilter or something similar, not 
necessarily netfilter itself?

rick jones
