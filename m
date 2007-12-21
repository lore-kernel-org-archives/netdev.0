From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] XFRM: Assorted IPsec fixups
Date: Thu, 20 Dec 2007 20:49:43 -0800 (PST)
Message-ID: <20071220.204943.215363882.davem@davemloft.net>
References: <20071220214200.12122.89628.stgit@flek.lan>
	<20071220214219.12122.57208.stgit@flek.lan>
	<Xine.LNX.4.64.0712210925130.27551@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, linux-audit@redhat.com,
	latten@austin.ibm.com
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50121
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753749AbXLUEto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:49:44 -0500
In-Reply-To: <Xine.LNX.4.64.0712210925130.27551@us.intercode.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Morris <jmorris@namei.org>
Date: Fri, 21 Dec 2007 09:25:38 +1100 (EST)

> On Thu, 20 Dec 2007, Paul Moore wrote:
> 
> > This patch fixes a number of small but potentially troublesome things in the
> > XFRM/IPsec code:
> > 
> >  * Use the 'audit_enabled' variable already in include/linux/audit.h
> >    Removed the need for extern declarations local to each XFRM audit fuction
> > 
> >  * Convert 'sid' to 'secid' everywhere we can
> >    The 'sid' name is specific to SELinux, 'secid' is the common naming
> >    convention used by the kernel when refering to tokenized LSM labels,
> >    unfortunately we have to leave 'ctx_sid' in 'struct xfrm_sec_ctx' otherwise
> >    we risk breaking userspace
> > 
> >  * Convert address display to use standard NIP* macros
> >    Similar to what was recently done with the SPD audit code, this also also
> >    includes the removal of some unnecessary memcpy() calls
> > 
> >  * Move common code to xfrm_audit_common_stateinfo()
> >    Code consolidation from the "less is more" book on software development
> > 
> >  * Proper spacing around commas in function arguments
> >    Minor style tweak since I was already touching the code
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied.
