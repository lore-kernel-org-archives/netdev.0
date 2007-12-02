From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 18:14:38 -0700
Message-ID: <m1abot524h.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
	<20071201113815.5df0960a@freepuppy.rosehill>
	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com> <4751C238.6010609@rtr.ca>
	<20071201122926.5c887588@laptopd505.fenrus.org>
	<4751DC3C.1050606@rtr.ca> <m1tzn23t6k.fsf@ebiederm.dsl.xmission.com>
	<4751ED1A.6020400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Lord <lkml@rtr.ca>, Arjan van de Ven <arjan@infradead.org>,
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
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58149 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753406AbXLBBQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 20:16:53 -0500
In-Reply-To: <4751ED1A.6020400@gmail.com> (Jiri Slaby's message of "Sun, 02
	Dec 2007 00:24:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby <jirislaby@gmail.com> writes:

> On 12/02/2007 12:13 AM, Eric W. Biederman wrote:
>> Mark Lord <lkml@rtr.ca> writes:
>>> Fine.  But all of them want to call sk_alloc(),
>> 
>> network drivers should be calling sk_alloc less then they should
>> call dev_get_by_XXXX.  Only protocols call sk_alloc.
>> 
>>> and many want to do register_netdev().
>> 
>> I haven't even touched register_netdev.
>> 
>>> So what should they be using there ?
>> 
>> What are you having problems with?
>> 
>> It is hard to answer specific questions without a context.
>
> VMware vmnet.

With a quick glance in that direction it appears to the result
of a design bug in vmnet that they call sk_alloc at all, and someone
seems to have found a work around in vmnet for this situation.

My gut feel is that vmware should just use tun or tap (whichever
is the appropriate one), and be done with it.

Eric
