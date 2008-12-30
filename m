From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] locking, percpu counters: introduce separate lock
	classes
Date: Tue, 30 Dec 2008 07:56:50 +0100
Message-ID: <20081230065650.GD30975@elte.hu>
References: <20081229141417.GA1493@elte.hu> <20081230035815.GA16454@gondor.apana.org.au> <20081230060536.GG11037@elte.hu> <20081229.223945.149941966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, a.p.zijlstra@chello.nl,
	emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, dada1@cosmosbay.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:34958 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202AbYL3G5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 01:57:10 -0500
Content-Disposition: inline
In-Reply-To: <20081229.223945.149941966.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 30 Dec 2008 07:05:36 +0100
> 
> > One small nit: could you please add the Reported-by line for Jeff Kirscher 
> > who reported the problem originally:
> > 
> >  Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> 
> I'll make sure to add that to the commit message after
> you successfully test Herbert's patch.
> 
> Thanks.

early indications are good: after about 15 random bootup tests the lockdep 
warning has not triggered. (it would trigger on every 2nd kernel before 
that - there's a 66% chance for lockdep to be enabled in my randconfig 
tests)

	Ingo
