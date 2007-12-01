From: Mark Lord <lkml@rtr.ca>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 17:12:12 -0500
Message-ID: <4751DC3C.1050606@rtr.ca>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>	<47515D39.9030900@rtr.ca>	<20071201111736.297dd99a@freepuppy.rosehill>	<20071201192341.6750fbdb@the-village.bc.nu>	<20071201113815.5df0960a@freepuppy.rosehill>	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com>	<4751C238.6010609@rtr.ca> <20071201122926.5c887588@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
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
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtr.ca ([76.10.145.34]:4570 "EHLO mail.rtr.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbXLAWMP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 17:12:15 -0500
In-Reply-To: <20071201122926.5c887588@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> On Sat, 01 Dec 2007 15:21:12 -0500
> Mark Lord <lkml@rtr.ca> wrote:
> 
>> Eric W. Biederman wrote:
>>> Stephen Hemminger <shemminger@linux-foundation.org> writes:
>>> Sure.  We keep the updated dev_get_by_XXXX that takes a network
>>> namespace parameter.
>> ..
>>
>> And what should code be passing in when "# CONFIG_NET_NS is not set" ?
> 
> network drivers probably really really don't want to call
> dev_get_by_XXX...
..

Fine.  But all of them want to call sk_alloc(),
and many want to do register_netdev().

So what should they be using there ?
