From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 16:13:07 -0700
Message-ID: <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
	<20071201113815.5df0960a@freepuppy.rosehill>
	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com> <4751C238.6010609@rtr.ca>
	<20071201122926.5c887588@laptopd505.fenrus.org>
	<4751DC3C.1050606@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:48676 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354AbXLAXQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 18:16:17 -0500
In-Reply-To: <4751DC3C.1050606@rtr.ca> (Mark Lord's message of "Sat, 01 Dec
	2007 17:12:12 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Lord <lkml@rtr.ca> writes:

> Arjan van de Ven wrote:
>> On Sat, 01 Dec 2007 15:21:12 -0500
>> Mark Lord <lkml@rtr.ca> wrote:
>>
>>> Eric W. Biederman wrote:
>>>> Stephen Hemminger <shemminger@linux-foundation.org> writes:
>>>> Sure.  We keep the updated dev_get_by_XXXX that takes a network
>>>> namespace parameter.
>>> ..
>>>
>>> And what should code be passing in when "# CONFIG_NET_NS is not set" ?
>>
>> network drivers probably really really don't want to call
>> dev_get_by_XXX...
> ..
>
> Fine.  But all of them want to call sk_alloc(),

network drivers should be calling sk_alloc less then they should
call dev_get_by_XXXX.  Only protocols call sk_alloc.

> and many want to do register_netdev().

I haven't even touched register_netdev.

> So what should they be using there ?

What are you having problems with?

It is hard to answer specific questions without a context.

Eric
