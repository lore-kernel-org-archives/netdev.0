From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 03:04:49 +0200
Message-ID: <200607250304.49227.ak@suse.de>
References: <20060724.162250.55836503.davem@davemloft.net> <20060724.174518.52116903.davem@davemloft.net> <44C56BFC.7080000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:5286 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932371AbWGYBFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 21:05:36 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44C56BFC.7080000@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Even enough bits for 1024 or 2048 CPUs in the single system image? 

MSI-X supports 255 sub interrupts max, most hardware probably much less
(e.g. 8 seems to be a popular number). 

It can be always hashed to the existing CPUs.

It's a nice idea but I think standard hashing + processing in softirq 
would be worth a try first at least.

-Andi
