From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] smsc-ircc2: wrap PNP probe code in #ifdef
 CONFIG_PNP
Date: Fri, 2 May 2008 14:38:02 -0700
Message-ID: <20080502143802.8fb86319.akpm@linux-foundation.org>
References: <200805022040.m42KeN16013646@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: samuel@sortiz.org, netdev@vger.kernel.org, bjorn.helgaas@hp.com,
	kamalesh@linux.vnet.ibm.com, sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33380 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764904AbYEBVjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 17:39:07 -0400
In-Reply-To: <200805022040.m42KeN16013646@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 May 2008 13:40:23 -0700
akpm@linux-foundation.org wrote:

> From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
> Wrap PNP probe code in #ifdef CONFIG_PNP.
> 
> Without this change, we'll have unresolved references to pnp_get_resource()
> function when CONFIG_PNP=n.  (This is a new interface that's not in mainline
> yet.)

hrm, it turns out that this is already in linux-next, only I'm
not sure by what route it got there.
