From: Olaf Kirch <okir@suse.de>
Subject: Re: 2.6.19-rc1: Volanomark slowdown
Date: Thu, 9 Nov 2006 10:21:31 +0100
Message-ID: <20061109092131.GA19715@suse.de>
References: <1162924354.10806.172.camel@localhost.localdomain> <1163001318.3138.346.camel@laptopd505.fenrus.org> <20061108162955.GA4364@suse.de> <1163011132.10806.189.camel@localhost.localdomain> <20061108221028.GA16889@suse.de> <1163023652.10806.203.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, davem@sunset.davemloft.net,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35734 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1754798AbWKIJVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 04:21:41 -0500
To: Tim Chen <tim.c.chen@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <1163023652.10806.203.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 08, 2006 at 02:07:32PM -0800, Tim Chen wrote:
> In my testing, the CPU utilization is at 100%.  So
> increase in ACKs will cost CPU to devote more
> time to process those ACKs and reduce throughput.

Oh, I see. I would test on a real network with real clients. I doubt
you would observe a noticeable effect there.

Olaf
-- 
Walks like a duck. Quacks like a duck. Must be a chicken.
