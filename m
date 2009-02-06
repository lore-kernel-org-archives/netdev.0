From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] forcedeth: make msi-x different name for rx-tx
Date: Fri, 6 Feb 2009 15:49:48 +0100
Message-ID: <20090206144948.GD18368@elte.hu>
References: <498BC3A8.9040203@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:59795 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbZBFOuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 09:50:07 -0500
Content-Disposition: inline
In-Reply-To: <498BC3A8.9040203@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Cool cleanups!

Would you mind to also fix the following - on all my systems that have 
forcedeth gigabit ethernet i've been getting these bogus warnings for 
_years_, under moderate load:

  eth2: too many iterations (16) in nv_nic_irq.

I think a 64 iterations limit will work much better. (i tried a limit of 50 
a year ago for a while and it worked fine and had no side effects - and the 
bogus warnings were done.)

	Ingo

