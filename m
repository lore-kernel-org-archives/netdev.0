From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/5] forcedeth: several proposed updates for testing
Date: Sun, 7 Oct 2007 11:08:08 +0200
Message-ID: <20071007090808.GB733@elte.hu>
References: <20071006151250.GA17020@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:41257 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbXJGJI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 05:08:29 -0400
Content-Disposition: inline
In-Reply-To: <20071006151250.GA17020@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jeff Garzik <jeff@garzik.org> wrote:

> * I feel TX NAPI is a useful tool, because it provides an independent TX
>   process control point and system load feedback point.
>   Thus I felt this was slightly superior to tasklets.

/me agrees violently

btw., when i played with this tunable under -rt:

 enum {
         NV_OPTIMIZATION_MODE_THROUGHPUT,
         NV_OPTIMIZATION_MODE_CPU
 };
 static int optimization_mode = NV_OPTIMIZATION_MODE_THROUGHPUT;

the MODE_CPU one gave (much) _higher_ bandwidth. The queueing model in 
forcedeth seemed to be not that robust and i think a single queueing 
model should be adopted instead of this tunable. (which i think just hid 
some bug/dependency) But i never got to the bottom of it so it's just 
the impression i got.

	Ingo
