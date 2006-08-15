From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/13] ppp: handle kmalloc() failures
Date: Tue, 15 Aug 2006 03:29:08 -0700 (PDT)
Message-ID: <20060815.032908.94558128.davem@davemloft.net>
References: <200608150603.k7F63chF012930@shell0.pdx.osdl.net>
	<17633.40289.120307.571499@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, takis@issaris.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3731
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965368AbWHOK3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 06:29:07 -0400
To: paulus@samba.org
In-Reply-To: <17633.40289.120307.571499@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Tue, 15 Aug 2006 20:09:37 +1000

> secondly, this is a bit rude, isn't it, destroying the whole thing
> because one insertion failed?  Some existing pppd will come along and
> try to use its (previously successfully created) ppp unit and get told
> it doesn't exist any more!

Less rude than an OOPS from accessing NULL though :-)

Ok, I'll wait for a better version of this patch, but
I'd like to see a fixed up version soon because this
does fix a real bug.
