From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND 1/2] in-kernel sockets API
Date: Mon, 07 Aug 2006 18:50:13 -0700 (PDT)
Message-ID: <20060807.185013.131106038.davem@davemloft.net>
References: <1154991629.11916.5.camel@w-sridhar2.beaverton.ibm.com>
	<20060807162033.3685924e@localhost.localdomain>
	<20060808005619.GN29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, sri@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19394
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751201AbWHHBuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 21:50:11 -0400
To: viro@ftp.linux.org.uk
In-Reply-To: <20060808005619.GN29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Tue, 8 Aug 2006 01:56:19 +0100

> On Mon, Aug 07, 2006 at 04:20:33PM -0700, Stephen Hemminger wrote:
> > Please consider EXPORT_SYMBOL_GPL because this interface would be a obvious
> > target for binary modules writers to use.
> 
> As opposed to duplicating it?  WTFPoint of restriction that is trivial to
> bypass?  Look at those functions; there's nothing that couldn't be
> immediately open-coded in a binary module and use of _GPL doesn't serve
> any purpose.

Agreed.
