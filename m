From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take3 0/4] kevent: Generic event handling mechanism.
Date: Thu, 3 Aug 2006 13:40:55 +0400
Message-ID: <20060803094055.GA19635@2ka.mipt.ru>
References: <20060731103322.GA1898@2ka.mipt.ru> <11545983592236@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34713 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932443AbWHCJlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 05:41:39 -0400
To: lkml <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11545983592236@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 01:45:59PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Changes from 'take2' patchset:
>  * split kevent_finish_user() to locked and unlocked variants
>  * do not use KEVENT_STAT ifdefs, use inline functions instead
>  * use array of callbacks of each type instead of each kevent callback initialization
>  * changed name of ukevent guarding lock
>  * use only one kevent lock in kevent_user for all hash buckets instead of per-bucket locks
>  * do not use kevent_user_ctl structure instead provide needed arguments as syscall parameters
>  * various indent cleanups
>  * mapped buffer (initial) implementation (no userspace yet)

Also added optimisation aimed to help when a lot of kevents are being
copied from userspace in one syscall.

-- 
	Evgeniy Polyakov
