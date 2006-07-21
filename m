From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 11:19:00 +0400
Message-ID: <20060721071900.GB5151@2ka.mipt.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru> <44BFF3F5.3040104@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20708 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161006AbWGUHTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 03:19:15 -0400
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <44BFF3F5.3040104@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2006 at 02:21:57PM -0700, Ben Greear (greearb@candelatech.com) wrote:
> Out of curiosity, is it possible to have the single producer logic
> if you have two+ ethernet interfaces handling frames for a single
> TCP connection?  (I am assuming some sort of multi-path routing
> logic...)

I do not think it is possible with additional logic like what is
implemented in softirqs, i.e. per cpu queues of data, which in turn will
be converted into skbs one-by-one.

> Thanks,
> Ben

-- 
	Evgeniy Polyakov
