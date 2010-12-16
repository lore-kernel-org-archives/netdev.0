From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] be2net: use mutex instead of spin lock for
 mbox_lock
Date: Thu, 16 Dec 2010 14:12:00 -0800 (PST)
Message-ID: <20101216.141200.242127421.davem@davemloft.net>
References: <1292336483.20458.1.camel@bwh-desktop>
	<1292341399-14353-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathyap@serverengines.com,
	subbus@serverengines.com, sarveshwarb@serverengines.com,
	ajitk@serverengines.com, bhutchings@solarflare.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754040Ab0LPWLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:11:31 -0500
In-Reply-To: <1292341399-14353-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Tue, 14 Dec 2010 16:43:19 +0100

> On Tue, 2010-12-14 at 14:21 +0000, Ben Hutchings wrote:
>> On Tue, 2010-12-14 at 14:46 +0100, Ivan Vecera wrote:
>> > Since the mbox polling uses the schedule_timeout, the mbox_lock should be
>> > a semaphore and not a spin lock.
>> > The commit f25b03a replaced udelay() with schedule_timeout() but didn't
>> > change the mbox_lock to a semaphore or a mutex.
>> [...]
>> 
>> I see no reason for this to be a semaphore; use a mutex instead.
>> 
>> Ben
> Ok, Ben... the new version
> 
> Since the mbox polling uses the schedule_timeout, the mbox_lock should be
> a mutex and not a spin lock.
> The commit f25b03a replaced udelay() with schedule_timeout() but didn't
> change mbox_lock to semaphore or mutex.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
