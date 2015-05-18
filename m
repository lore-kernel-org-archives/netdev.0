From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 10/13] xen-netfront: refactor claim/release
 grant
Date: Mon, 18 May 2015 16:48:33 +0100
Message-ID: <555A09D1.50902@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-11-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:63425 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704AbbERPsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:48:39 -0400
In-Reply-To: <1431451117-70051-11-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> Refactors how grants are claimed/released/revoked by moving that code
> into claim_grant and release_grant helpers routines that can be shared
> in both TX/RX path.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

But should this be generic?  Is it useful to other frontends?  And some
of the line splitting looks a bit odd.

David
