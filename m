From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 0/2] Tracepoint for tcp retransmission
Date: Fri, 16 Dec 2011 16:17:17 -0800 (PST)
Message-ID: <5f654c7d-f18e-4d70-8830-a3e31b8f5f4a@tahiti.vyatta.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net, tgraf@infradead.org,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	dle-develop@lists.sourceforge.net, netdev@vger.kernel.org
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45098 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591Ab1LQARS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 19:17:18 -0500
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Sometimes network packets are dropped for some reason. In enterprise
> systems which require strict RAS functionality, we must know the
> reason why it happened and explain it to our customers even if using
> TCP. When we investigate the incidents, at first we try to find out
> whether the problem is in the server(kernel, application) or else
> (router, hub etc). And next we try to find out which layer
> (application/middleware/kernel(IP/TCP/UDP/..)etc.) the problem
> occurs.

I feel sorry for you, your users don't understand TCP. TCP intentionally induces loss
to measure capacity. This is one of the fundamental principles of
loss based congestion control.
