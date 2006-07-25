From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 18:32:05 +0200
Message-ID: <200607251832.05687.ak@suse.de>
References: <44C565D1.6070202@hp.com> <20060724.182108.37154478.davem@davemloft.net> <44C646D7.3040701@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:45980 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S964787AbWGYQcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:32:54 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44C646D7.3040701@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It may be a hardware interpretation, but doesn't it have non-trivial system 
> implications - where one runs threads/processes etc?

Only if you do process context RX processing. If you chose not to it doesn't 
have much influence.

-Andi
