From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] skye/skge: sparse fix - data can't ever be bigger than
 LONG_MAX / HZ
Date: Fri, 26 Oct 2007 15:12:40 -0700
Message-ID: <20071026151240.0ce5f7ec@freepuppy.rosehill>
References: <20071026221028.1873.3005.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59642 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753314AbXJZWNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 18:13:12 -0400
In-Reply-To: <20071026221028.1873.3005.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Oct 2007 15:10:28 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> Trivial replacement - use INT_MAX instead here.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: shemminger@linux-foundation.org

Acked-by: Stephen Hemminger <shemminger@linux-foundation.org>

Sure that works. Note: original code was copied from e100 which I assume
is why you found/fixed this case.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
