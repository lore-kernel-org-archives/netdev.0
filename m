From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: delay via-rhine irq initialisation.
Date: Wed, 02 Jan 2008 18:34:21 -0500
Message-ID: <477C1F7D.2040201@redhat.com>
References: <20071211233909.GA22470@redhat.com> <476DD7CC.9090507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbYABXed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2008 18:34:33 -0500
In-Reply-To: <476DD7CC.9090507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2007 10:36 PM, Jeff Garzik wrote:
> Dave Jones wrote:
>> With CONFIG_DEBUG_SHIRQ set, via-rhine complains during init.
>> (See https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=377721 for a
>> report).
> 
> Absolutely we want to do this.  DEBUG_SHIRQ is only one of many reasons
> -- quite simply, you are fixing an order-of-init bug that leads to races
> and other badness.
> 

Such bugs seem to be more common than was thought.  hisax_fcpcipnp has the
same problem -- it assigns function pointers for driver interrupt processing
after it requests an interrupt.
