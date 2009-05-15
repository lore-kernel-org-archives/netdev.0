From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Fri, 15 May 2009 11:12:14 +0000
Message-ID: <20090515111213.GA6807@ff.dom.local>
References: <20090514172954.GA3867@hmsreliant.think-freely.org> <20090515054947.GA4497@ff.dom.local> <20090515110141.GB7745@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:39735 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbZEOLMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 07:12:20 -0400
Received: by fxm2 with SMTP id 2so1851345fxm.37
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 04:12:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090515110141.GB7745@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 07:01:41AM -0400, Neil Horman wrote:
> On Fri, May 15, 2009 at 05:49:47AM +0000, Jarek Poplawski wrote:
...
> > IMHO it looks worse now. rcu_read_lock() suggests it's a read side,
> > and spin_lock(&trace_state_lock) protects something else.
> > 
> the read lock is required (according to the comments for the list loop
> primitive) to protect against the embedded mutation primitive, so its required.
> I understand that its a bit counterintuitive, but intuition takes a backseat to
> functionality. :)
> Neil
> 

I guess, you missed:

> Looks good from an RCU viewpoint!
> 
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

for the previous version...

Jarek P.
