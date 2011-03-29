From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH v2] ROSE: prevent heap corruption with bad facilities
Date: Tue, 29 Mar 2011 18:26:50 +0200
Message-ID: <20110329162650.GA31255@linux-mips.org>
References: <1300603423.1869.18.camel@dan>
 <1300639685.26693.286.camel@localhost>
 <20110327.175936.189721420.davem@davemloft.net>
 <1301361379.26693.742.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: drosenberg@vsecurity.com, netdev@vger.kernel.org,
	security@kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:32983 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750Ab1C2Q05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 12:26:57 -0400
Received: from localhost.localdomain ([127.0.0.1]:33125 "EHLO
        duck.linux-mips.net" rhost-flags-OK-OK-OK-FAIL)
        by eddie.linux-mips.org with ESMTP id S2100780Ab1C2Q04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 18:26:56 +0200
Content-Disposition: inline
In-Reply-To: <1301361379.26693.742.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 29, 2011 at 02:16:19AM +0100, Ben Hutchings wrote:

> On Sun, 2011-03-27 at 17:59 -0700, David Miller wrote:
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Sun, 20 Mar 2011 16:48:05 +0000
> > 
> > > Subject: [PATCH] rose: Add length checks to CALL_REQUEST parsing
> > > 
> > > Define some constant offsets for CALL_REQUEST based on the description
> > > at <http://www.techfest.com/networking/wan/x25plp.htm> and the
> > > definition of ROSE as using 10-digit (5-byte) addresses.  Use them
> > > consistently.  Validate all implicit and explicit facilities lengths.
> > > Validate the address length byte rather than either trusting or
> > > assuming its value.
> > > 
> > > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > 
> > Applied.
> 
> Ralf, I would really appreciate it if you could test this soon...

Actual testing is a problem atm.  But I've reviewed the patche and it appears
ok.

Acked-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf
