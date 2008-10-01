From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 08/16] netlabel: Replace protocol/NetLabel linking
 with refrerence counts
Date: Wed, 1 Oct 2008 19:01:43 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011901140.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125638.17132.26966.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:45441 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755516AbYJAJBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 05:01:47 -0400
In-Reply-To: <20080916125638.17132.26966.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2008, Paul Moore wrote:

> NetLabel has always had a list of backpointers in the CIPSO DOI definition
> structure which pointed to the NetLabel LSM domain mapping structures which
> referenced the CIPSO DOI struct.  The rationale for this was that when an
> administrator removed a CIPSO DOI from the system all of the associated
> NetLabel LSM domain mappings should be removed as well; a list of
> backpointers made this a simple operation.
> 
> Unfortunately, while the backpointers did make the removal easier they were
> a bit of a mess from an implementation point of view which was making
> further development difficult.  Since the removal of a CIPSO DOI is a
> realtively rare event it seems to make sense to remove this backpointer
> list as the optimization was hurting us more then it was helping.  However,
> we still need to be able to track when a CIPSO DOI definition is being used
> so replace the backpointer list with a reference count.  In order to
> preserve the current functionality of removing the associated LSM domain
> mappings when a CIPSO DOI is removed we walk the LSM domain mapping table,
> removing the relevant entries.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Reviewed-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
