From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/2] fix several unaligned kernel accesses in the CIPSO
 engine
Date: Thu, 7 Jun 2007 21:20:20 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0706072120050.10435@d.namei>
References: <20070607153226.524778346@hp.com> <20070607153610.888828690@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:43514 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965585AbXFHBUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:20:23 -0400
In-Reply-To: <20070607153610.888828690@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jun 2007, Paul Moore wrote:

> IPv4 options are not very well aligned within the packet and the format of a
> CIPSO option is even worse.  The result is that the CIPSO engine in the kernel
> does a few unaligned accesses when parsing and validating incoming packets with
> CIPSO options attached which generate error messages on certain alignment
> sensitive platforms.  This patch fixes this by marking these unaligned accesses
> with the get_unaliagned() macro.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>


Acked-by: James Morris <jmorris@namei.org>


