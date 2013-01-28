From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] pktgen: use the net namespace of current
 process instead of init_net
Date: Mon, 28 Jan 2013 10:57:32 +0800
Message-ID: <1359341852.20444.10.camel@cr0>
References: <1359340387-18004-1-git-send-email-amwang@redhat.com>
	 <87mwvu10rj.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029Ab3A1C5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jan 2013 21:57:38 -0500
In-Reply-To: <87mwvu10rj.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-27 at 18:48 -0800, Eric W. Biederman wrote:
> Cong Wang <amwang@redhat.com> writes:
> 
> > From: Cong Wang <amwang@redhat.com>
> >
> > Use the net namespace of the current process loading
> > pktgen module.
> 
> Why not add proper support for multiple network namespaces?
> 
> It looks like the proc files could be created in each network namespace
> and be controlled from there.

Hmm, I didn't think much about this. You are right... we could probably
make these proc files per-net.

> 
> Your patch below looks like it could have some unintended effects
> if pktgen was loaded automatically or compiled into the kernel.
> 

In this case, 'current' should be the init process whose net namespace
is init_net, no?

Thanks.
