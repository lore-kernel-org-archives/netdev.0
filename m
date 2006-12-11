From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 20/22] e1000: Fix poor quad port performance with NAPI
Date: Mon, 11 Dec 2006 09:49:11 -0500
Message-ID: <457D6FE7.9010100@pobox.com>
References: <20061208230209.30109.49157.stgit@gitlost.site> <20061208230329.30109.85896.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46423 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762920AbWLKOtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:49:13 -0500
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20061208230329.30109.85896.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> This fix attempts to solve a customer reported issue with NAPI enabled
> e1000 having bad performance when transmitting simultaneously on
> four ports.  The issue comes down to an interaction between NAPI
> hardware interrupt balancing, and the driver rescheduling poll on
> the same processor.
> 
> We try to fix by allowing the driver to re-enable interrupts sooner
> instead of polling one more time, when there was recently all the
> work completed in cleanup.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

ACK patches 16-20


