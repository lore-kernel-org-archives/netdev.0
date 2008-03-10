From: "Tom Herbert" <therbert@google.com>
Subject: Re: RFC [PATCH net-2.6 1/6] net: Scheduling softirqs between CPUSs
Date: Mon, 10 Mar 2008 16:26:54 -0700
Message-ID: <65634d660803101626y4c385a44g933b33f1405e4a5a@mail.gmail.com>
References: <20080305205116.5989A412541@localhost>
	 <20080305.132112.01598419.davem@davemloft.net>
	 <47D19147.9070609@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"Steven Rostedt" <rostedt@goodmis.org>,
	"Ingo Molnar" <mingo@elte.hu>
To: "Max Krasnyanskiy" <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:54340 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbYCJX1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 19:27:00 -0400
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id m2ANQtvg012873
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 16:26:55 -0700
Received: from rv-out-0910.google.com (rvbk20.prod.google.com [10.140.87.20])
	by zps38.corp.google.com with ESMTP id m2ANQs17031298
	for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 16:26:54 -0700
Received: by rv-out-0910.google.com with SMTP id k20so1691317rvb.30
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2008 16:26:54 -0700 (PDT)
In-Reply-To: <47D19147.9070609@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Plus it seems that for this kind of stuff it be better to replace network
> softirq with kthreads (like in -rt kernel) and let the scheduler take care of
> the load balancing. More flexible and scalable.
> I'd suggest for your to play with -rt kernel and see if it already does what
> you need.

We looked a bit at using the ksoftirqd thread for that, but that
seemed to have more complexity and overhead as a solution.

I didn't look at -r kernel though, thanks for the pointer to that.

Tom
