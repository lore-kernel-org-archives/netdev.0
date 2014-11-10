From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] cxgb4: Remove unnecessary struct in6_addr *
 casts
Date: Mon, 10 Nov 2014 10:48:18 -0800
Message-ID: <1415645298.8868.10.camel@perches.com>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
	 <1415333125-10635-2-git-send-email-hariprasad@chelsio.com>
	 <1415335574.23530.4.camel@perches.com>
	 <20141110.132837.1817456437352515704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, leedom@chelsio.com,
	anish@chelsio.com, praveenm@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:32931 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751228AbaKJSsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:48:23 -0500
In-Reply-To: <20141110.132837.1817456437352515704.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-10 at 13:28 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com> Date: Thu, 06 Nov 2014 20:46:14 -0800
[]
> >> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > []
> >>  #include <../drivers/net/bonding/bonding.h>
> > 
> > This include path seems unfortunate so I looked 
> > at the code a bit.  I don't see an easy way to change it.
> > 
> > Maybe some of bonding.h should be moved into a new file
> > like 'include/net/bonding.h' or something.
> 
> I just committed the following into net-next, thanks for pointing
> this out.

Thanks.

btw: using "git format-patch -M" makes reading and
verifying the patch a lot easier.

Unfortunately, there's no current way to make this
a global default for everyone, but I have this in
my ~/.gitconfig:

[diff]
	renames = true
