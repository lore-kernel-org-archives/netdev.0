From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Mon, 22 Oct 2007 11:57:17 -0700
Message-ID: <7038.1193079437@death>
References: <11920760494096-git-send-email-fubar@us.ibm.com> <11920760502756-git-send-email-fubar@us.ibm.com> <4713B44E.7030902@pobox.com> <20038.1192475339@death> <170fa0d20710220755w744e8ec8w1d85cae4f4be822e@mail.gmail.com> <471CED48.207@garzik.org>
Cc: Mike Snitzer <snitzer@gmail.com>, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:46290 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553AbXJVS5Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 14:57:25 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9MIvOJs012991
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:57:24 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9MIvOPs092352
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:57:24 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9MIvNpe020699
	for <netdev@vger.kernel.org>; Mon, 22 Oct 2007 14:57:24 -0400
In-reply-to: <471CED48.207@garzik.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
[...]
>I wasn't aware this brand-new code is a bug fix?
>
>Normally brand new code needs to be posted and reviewed and committed to a
>tree -before- the merge window opens.

	I had thought this was going in ok, as you'd attempted to apply
it after the IPoIB stuff a week or so ago, but it needed to be rebased
and you'd had concerns about bisect.

	In any event, I'd argue it's changes to fix locking bugs
(various "sleep with lock held" and ASSERT_RTNLs, e.g., bug 7974 on
bugzilla.kernel.org); this isn't a feature add or a refactor just for
efficiency.

	 -J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
