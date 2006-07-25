From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RDMA will be reverted
Date: Mon, 24 Jul 2006 18:03:50 -0700
Message-ID: <44C56DF6.3020509@hp.com>
References: <20060724.162250.55836503.davem@davemloft.net>	<200607250202.02913.ak@suse.de> <44C565D1.6070202@hp.com> <20060724.174518.52116903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:27350 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932368AbWGYBEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 21:04:16 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.174518.52116903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It would have to be done in such a way as to not make the PAWS
> tests fail by accident.  But I think it's doable.

CPU ID and higher-order generation number such that whenever the process 
migrates to a lower-numbered CPU, the generation number is bumped to make the 
timestamp larger than before?

rick jones
