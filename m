From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH -net] netpoll: fix NULL pointer dereference in netpoll_cleanup
Date: Tue, 17 Sep 2013 20:06:57 +0200
Message-ID: <52389A41.4050702@redhat.com>
References: <1379427155-8561-1-git-send-email-nikolay@redhat.com> <52386911.2010504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144Ab3IQSHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 14:07:01 -0400
In-Reply-To: <52386911.2010504@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2013 04:37 PM, Nikolay Aleksandrov wrote:
> commit 7a163bfb7ce50895bbe67300ea610d31b9c09230
> ("netconsole: avoid a crash with multiple sysfs writers")
I feel like I didn't explain this one well. The above commit actually
tries to fix the same issue AFAICT, and it can be reverted if/once my fix
is accepted, but I think to remove only the locking in the netconsole
netdev notifier to avoid the deadlock because the mutex lock is useful for
fixing a third bug in netconsole, that I intend to take care of once this
is sorted out.
So basically my next fix that takes care of the deadlock is dependent on
this patch, and I'll wait to see the feedback, if it gets accepted I'll
post the follow-up that takes care of the deadlock.

Cheers,
 Nik
