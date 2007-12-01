From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 12:29:26 -0800
Message-ID: <20071201122926.5c887588@laptopd505.fenrus.org>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
	<20071201192341.6750fbdb@the-village.bc.nu>
	<20071201113815.5df0960a@freepuppy.rosehill>
	<m13aum5g1x.fsf@ebiederm.dsl.xmission.com>
	<4751C238.6010609@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: Mark Lord <lkml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48803 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbXLAUay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 15:30:54 -0500
In-Reply-To: <4751C238.6010609@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 01 Dec 2007 15:21:12 -0500
Mark Lord <lkml@rtr.ca> wrote:

> Eric W. Biederman wrote:
> > Stephen Hemminger <shemminger@linux-foundation.org> writes:
> > Sure.  We keep the updated dev_get_by_XXXX that takes a network
> > namespace parameter.
> ..
> 
> And what should code be passing in when "# CONFIG_NET_NS is not set" ?

network drivers probably really really don't want to call
dev_get_by_XXX...

in fact no NIC driver in drivers/net does so!
Sounds like whatever driver you're looking at has a nasty bug in that
it's using non-driver APIs...



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
