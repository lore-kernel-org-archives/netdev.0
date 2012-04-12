From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] ks8851: Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 17:40:44 -0300
Message-ID: <20120412174044.2cd7d96b@asterix.rh>
References: <1334261204-8554-1-git-send-email-mjr@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sboyd@codeaurora.org, ben@simtec.co.uk,
	netdev@vger.kernel.org
To: mjr@cs.wisc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756749Ab2DLUlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 16:41:09 -0400
In-Reply-To: <1334261204-8554-1-git-send-email-mjr@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Apr 2012 15:06:44 -0500
mjr@cs.wisc.edu wrote:

> From: Matt Renzelmann <mjr@cs.wisc.edu>
> 
> All calls to ks8851_rdreg* and ks8851_wrreg* should be protected with
> the driver's lock mutex.  A spurious interrupt may otherwise cause a
> crash.
> 
> Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
> ---
> 
> Thank you, Mr. Leitner, for providing feedback.  I agree with your
> changes and have updated the patch to reflect them.  I apologize for
> missing the driver name in the title -- I've updated the patch with
> that information as well.  Please let me know if there is anything
> else I should fix/change.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
