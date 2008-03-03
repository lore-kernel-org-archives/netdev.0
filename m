From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 3 Mar 2008 09:35:18 +0000
Message-ID: <20080303093518.GB4066@ff.dom.local>
References: <20080226200033.GA6550@ami.dom.local> <47CB0E46.9000806@katalix.com> <20080303082204.GA4066@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:46897 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbYCCJeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 04:34:07 -0500
Received: by nf-out-0910.google.com with SMTP id g13so3310177nfb.21
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 01:34:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080303082204.GA4066@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 08:22:04AM +0000, Jarek Poplawski wrote:
...
> Maybe it would be interesting to try (in a test only)
> with calling this with reorder_q.lock held (so without unlocking
> inside this pppol2tp_recv_dequeue's loop at all: at least to see
> possible lockdep report.

...But we can't forget to change this skb_unlink() in
pppol2tp_recv_dequeue_skb() then...

Jarek P.
