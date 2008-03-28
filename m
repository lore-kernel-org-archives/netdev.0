From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Fri, 28 Mar 2008 14:38:45 +0100
Message-ID: <20080328133845.GA14565@ami.dom.local>
References: <47EC3182.7080005@sun.com> <20080327.170235.53674739.davem@davemloft.net> <47EC399E.90804@sun.com> <20080327.173418.18777696.davem@davemloft.net> <20080328012234.GA20465@gondor.apana.org.au> <47EC50BA.6080908@sun.com> <20080328103809.GB23039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	David Miller <davem@davemloft.net>, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.180]:37409 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbYC1NmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:42:21 -0400
Received: by el-out-1112.google.com with SMTP id v27so80771ele.17
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 06:42:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080328103809.GB23039@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 06:38:09PM +0800, Herbert Xu wrote:
...
> Given that premise, we might as well let one CPU transmit as much
> as possible since moving to another CPU after each packet is going
> to bounce a lot more than just the spin lock and that is going to
> be expensive.

Considering this, I wonder why using this __LINK_STATE_QDISC_RUNNING
flag to control enqueuing as well would be a wrong idea? Wouldn't this
enforce pseudo affinity?

Regards,
Jarek P.
