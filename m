From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [patch next 4/4] netxen: disable rss for GbE ports
Date: Thu, 7 May 2009 16:44:16 -0700
Message-ID: <4A037250.9040408@netxen.com>
References: <1241586309-12112-1-git-send-email-dhananjay@netxen.com> <1241586309-12112-5-git-send-email-dhananjay@netxen.com> <20090506.153714.122287244.davem@davemloft.net> <4A0217F6.7060005@netxen.com> <Pine.LNX.4.64.0905070811150.3058@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:52386 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751284AbZEGXoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 19:44:16 -0400
In-Reply-To: <Pine.LNX.4.64.0905070811150.3058@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jesper Dangaard Brouer wrote:
> 1Gbit/s throughput tests with MTU size frames is a bad measurement target.
> Packets Per Sec is the key factor.
> 

Yes, I will run some small packet tests before deciding on the number of
rx queues. I am going to revisit the msix vector utilization a bit later,
that's when I will address this.

Thanks,
Dhananjay
