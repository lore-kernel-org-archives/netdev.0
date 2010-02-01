From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 01/86] dccp: fix bug in cache allocation
Date: Mon, 1 Feb 2010 06:56:38 -0500
Message-ID: <20100201115638.GB25094@hmsreliant.think-freely.org>
References: <recent-dccp-bug-fixes-jan-2010>
 <1265005087-5549-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36424 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab0BAL4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 06:56:42 -0500
Content-Disposition: inline
In-Reply-To: <1265005087-5549-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 01, 2010 at 07:18:06AM +0100, Gerrit Renker wrote:
> This fixes a bug introduced in commit de4ef86cfce60d2250111f34f8a084e769f23b16
> ("dccp: fix dccp rmmod when kernel configured to use slub", 17 Jan): the
> vsnprintf used sizeof(slab_name_fmt), which became truncated to 4 bytes, since
> slab_name_fmt is now a 4-byte pointer and no longer a 32-character array.
> 
> This lead to error messages such as
>  FATAL: Error inserting dccp: No buffer space available
> 
>  >> kernel: [ 1456.341501] kmem_cache_create: duplicate cache cci
> generated due to the truncation after the 3rrdc character.
> 
> Fixed for the moment by introducing a symbolic constant. Tested to fix the bug.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

These changes make sense, sorry for not seeing that earlier.  Thanks!

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> 
