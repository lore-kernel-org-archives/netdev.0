From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH RESEND 1/2] in-kernel sockets API
Date: Tue, 8 Aug 2006 01:56:19 +0100
Message-ID: <20060808005619.GN29920@ftp.linux.org.uk>
References: <1154991629.11916.5.camel@w-sridhar2.beaverton.ibm.com> <20060807162033.3685924e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40667 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S932469AbWHHA40
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 20:56:26 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060807162033.3685924e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2006 at 04:20:33PM -0700, Stephen Hemminger wrote:
> Please consider EXPORT_SYMBOL_GPL because this interface would be a obvious
> target for binary modules writers to use.

As opposed to duplicating it?  WTFPoint of restriction that is trivial to
bypass?  Look at those functions; there's nothing that couldn't be
immediately open-coded in a binary module and use of _GPL doesn't serve
any purpose.
