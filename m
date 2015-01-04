From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rhashtable: fix missing header
Date: Sun, 4 Jan 2015 09:57:27 +0000
Message-ID: <20150104095727.GC15305@casper.infradead.org>
References: <1420356309-7382-1-git-send-email-ying.xue@windriver.com>
 <20150104091908.GA15305@casper.infradead.org>
 <54A906CF.7000309@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:39789 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbADJ52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 04:57:28 -0500
Content-Disposition: inline
In-Reply-To: <54A906CF.7000309@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/15 at 05:24pm, Ying Xue wrote:
> On 01/04/2015 05:19 PM, Thomas Graf wrote:
> > On 01/04/15 at 03:25pm, Ying Xue wrote:
> >> Fixup below build error:
> >>
> >> include/linux/rhashtable.h: At top level:
> >> include/linux/rhashtable.h:118:34: error: field ???mutex??? has incomplete type
> > 
> > Just wondering, is this your new code that didn't compile? The code
> > compiled fine for me for the existing users.
> > 
> 
> When I did below patch, I met the build error.

OK, personally I would squash it with that patch then as it's only
needed in combination with the new code.

> http://patchwork.ozlabs.org/patch/425149/
> 
> By the way, please help to review the patch if you have time :)

The convertion looks straight forward although I'm not fully familiar
with the TIPC code. I left a comment with a further optimization idea.
