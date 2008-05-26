From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Fix NULL pointer dereference and lockup.
Date: Mon, 26 May 2008 08:42:14 +0000
Message-ID: <20080526084213.GA4150@ff.dom.local>
References: <001a01c87692$cfca8d00$453c822c@dg8ngn> <20080224195101.GA2961@ami.dom.local> <20080526082345.GA27219@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jann Traschewski <jann@gmx.de>,
	Thomas Osterried <thomas@osterried.de>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:5011 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbYEZIi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 04:38:27 -0400
Received: by nf-out-0910.google.com with SMTP id d3so853508nfc.21
        for <netdev@vger.kernel.org>; Mon, 26 May 2008 01:38:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080526082345.GA27219@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 26, 2008 at 09:23:45AM +0100, Ralf Baechle wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> 
> There is only one function in AX25 calling skb_append(), and it really
> looks suspicious: appends skb after previously enqueued one, but in
> the meantime this previous skb could be removed from the queue.
> 
> This patch Fixes it the simple way, so this is not fully compatible with
> the current method, but testing hasn't shown any problems.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> ---
> I'm told Jarek is currently not reachable, so I'm submitting this for 2.6.26
> and -stable.

Acked-by: Jarek Poplawski <jarkao2@gmail.com>
