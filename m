From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] be2net: use semaphore instead of spin lock for
 mbox_lock
Date: Tue, 14 Dec 2010 14:21:23 +0000
Message-ID: <1292336483.20458.1.camel@bwh-desktop>
References: <1292334367-11148-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathyap@serverengines.com,
	subbus@serverengines.com, sarveshwarb@serverengines.com,
	ajitk@serverengines.com, davem@davemloft.net
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47293 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab0LNOV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 09:21:27 -0500
In-Reply-To: <1292334367-11148-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-12-14 at 14:46 +0100, Ivan Vecera wrote:
> Since the mbox polling uses the schedule_timeout, the mbox_lock should be
> a semaphore and not a spin lock.
> The commit f25b03a replaced udelay() with schedule_timeout() but didn't
> change the mbox_lock to a semaphore or a mutex.
[...]

I see no reason for this to be a semaphore; use a mutex instead.

Ben

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

