From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets - continued
Date: Thu, 10 Mar 2011 08:54:58 +0200
Message-ID: <20110310065457.GA22820@redhat.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
 <201103091411.09062.tahm@linux.vnet.ibm.com>
 <20110309215537.GA11516@redhat.com>
 <201103091725.12992.tahm@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com
To: Tom Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752242Ab1CJGz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 01:55:29 -0500
Content-Disposition: inline
In-Reply-To: <201103091725.12992.tahm@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2011 at 05:25:11PM -0600, Tom Lendacky wrote:
> As for which CPU the interrupt gets pinned to, that doesn't matter - see 
> below.

So what hurts us the most is that the IRQ jumps between the VCPUs?
