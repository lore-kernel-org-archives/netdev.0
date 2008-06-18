From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] ibm_emac: Remove the ibm_emac driver
Date: Tue, 17 Jun 2008 20:39:12 -0400
Message-ID: <20080617203912.4d51ddb9@zod.rchland.ibm.com>
References: <20080617193523.028d4cc2@zod.rchland.ibm.com>
	<20080617201127.6388ff78@lappy.seanm.ca>
	<1213749283.8129.259.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sean MacLennan <smaclennan@pikatech.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:52108 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757176AbYFRAlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 20:41:35 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5I0hhub018937
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 20:43:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5I0fE8v199356
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 20:41:14 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5I0fCEV027333
	for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 20:41:13 -0400
In-Reply-To: <1213749283.8129.259.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Jun 2008 10:34:43 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Tue, 2008-06-17 at 20:11 -0400, Sean MacLennan wrote:
> > On Tue, 17 Jun 2008 19:35:23 -0400
> > Josh Boyer <jwboyer@linux.vnet.ibm.com> wrote:
> > 
> > > The arch/ppc sub-tree has been removed in the powerpc git tree.  The
> > > old ibm_emac driver is no longer used by anything as a result of
> > > this.  This removes it, leaving the ibm_newemac driver as the proper
> > > driver to use for PowerPC boards with the EMAC hardware.
> > 
> > Would it make any sense to rename the ibm_newemac driver ibm_emac?
> 
> Yes.

One step at a time.

And really, that seems like a bunch of busy work for little gain.  We'd
have to move the files, change the Kconfig options, update all the
in-tree defconfigs... just so it can be called ibm_emac?

I don't really care either way, but I'll leave it up to the ibm_newemac
maintainer to push that change through.  If it goes in, I'll update
other things as needed.

josh
