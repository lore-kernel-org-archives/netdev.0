From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 16:38:26 +0000
Message-ID: <20150116163826.GD15052@casper.infradead.org>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45385 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbbAPQi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 11:38:29 -0500
Content-Disposition: inline
In-Reply-To: <20150116163202.GJ30132@acer.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/15 at 04:32pm, Patrick McHardy wrote:
> If we have to block, the dumper if of course preferred. Taking the
> mutex should do fine I guess?

That will work, it will also ensure that the walker doesn't see the
pre unzip state which would cause entries to be duplicated in the
walker.

> I suppose walking both tables without any races would be rather
> complicated.

Very interested if you can come up with something ;-)
