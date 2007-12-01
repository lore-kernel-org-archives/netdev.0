From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 01 Dec 2007 13:52:05 -0700
Message-ID: <m1y7ce3zpm.fsf@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca> <20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
	<20071201113815.5df0960a@freepuppy.rosehill>
	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com> <4751C238.6010609@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
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
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35946 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbXLAUyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 15:54:19 -0500
In-Reply-To: <4751C238.6010609@rtr.ca> (Mark Lord's message of "Sat, 01 Dec
	2007 15:21:12 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Lord <lkml@rtr.ca> writes:

>>> Can we get this resolved before 2.6.24 is released? Going back and forth
>>> on API's is just needless frottage.
>>
>> Sure.  We keep the updated dev_get_by_XXXX that takes a network
>> namespace parameter.
> ..
>
> And what should code be passing in when "# CONFIG_NET_NS is not set" ?

Mostly CONFIG_NET_NS is a define to keep us from exposing the feature to
user space not to remove the code impact.  People could not stand the
look of the code that would actually allow us to compile everything out.

So all of the struct net * fields remain when !CONFIG_NET_NS.
Including the global variable init_net.

Eric
