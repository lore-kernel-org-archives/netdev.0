From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 01/22] e1000: Fix early TSO completion
Date: Mon, 11 Dec 2006 09:36:14 -0500
Message-ID: <457D6CDE.8070400@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230246.30109.2309.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46272 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935864AbWLKOgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:36:17 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230246.30109.2309.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> This fix was already merged in commit 96f9c2e277768099479fbed7c3b69c294b1fadef
> but reverted in commit 989316ddfeafd0e8fb51a4d811383769ad62637a. After
> stresstesting we found that the fix does not add new regressions and
> works around a TX hang spotted by several users.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

ACK content except for one detail:  don't add new NETIF_F_TSO ifdefs. 
Modern 2.6 kernel code should simply assume that TSO is present.

	Jeff


