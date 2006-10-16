From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Mon, 16 Oct 2006 17:30:54 -0400
Message-ID: <20061016213053.GA16231@gospo.rdu.redhat.com>
References: <200610162021.12884.dpc@asn.pl> <200610162027.15100.dpc@asn.pl> <200610161850.k9GIogZt028527@death.nxdomain.ibm.com> <200610162107.57477.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32999 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161093AbWJPVbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 17:31:11 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
Content-Disposition: inline
In-Reply-To: <200610162107.57477.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2006 at 09:07:57PM +0200, Dawid Ciezarkiewicz wrote:
> > 
> > 	Before getting into the technical bits of the patch, what's the
> > reason for wanting to do this, and why is this rather complex manual
> > weight assignment better than an automatic system based on, e.g., link
> > speed of the slaves?
> 
> In short:
> It was designed as a solution for wireless links bonding - where link quality 
> can change rather quickly in time. By using wrr bonding, userspace tools can 
> measure current bandwidth and change bonding slave weights in realtime.

Since this is so similar to mode 0, it would seem there would be a way
to extend it rather than creating yet another mode that is so similar.
What would be the reason not to enhance that mode?

