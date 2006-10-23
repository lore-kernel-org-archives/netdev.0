From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: fix horizon init section usage
Date: Sun, 22 Oct 2006 21:39:55 -0700 (PDT)
Message-ID: <20061022.213955.85411282.davem@davemloft.net>
References: <20061022191309.73e3eacd.randy.dunlap@oracle.com>
	<20061022.203922.130845181.davem@davemloft.net>
	<453C45D4.6080904@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:9159
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751467AbWJWEjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 00:39:53 -0400
To: randy.dunlap@oracle.com
In-Reply-To: <453C45D4.6080904@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Randy.Dunlap" <randy.dunlap@oracle.com>
Date: Sun, 22 Oct 2006 21:32:20 -0700

> David Miller wrote:
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > Date: Sun, 22 Oct 2006 19:13:09 -0700
> > 
> >> From: Randy Dunlap <randy.dunlap@oracle.com>
> >>
> >> hrz_init() is called from the probe function, which is __devinit
> >> and could be called after init.
> >>
> >> WARNING: drivers/atm/horizon.o - Section mismatch: reference to .init.text:.hrz_init from .text between '.hrz_probe' (at offset 0x4054) and '.hrz_remove_one'
> >>
> >> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > It is only called from hrz_init() and thus shouldn't it be
> > thus marked __devinit as well?  That seems to be the right
> > way to fix this one.
> 
> Oops, I agree.  Want me to send another patch?

No need, I'll take care of it, thanks Randy.
