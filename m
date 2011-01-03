From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/3] Simplified 16 bit Toeplitz hash algorithm
Date: Mon, 03 Jan 2011 11:02:44 -0800 (PST)
Message-ID: <20110103.110244.183045594.davem@davemloft.net>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
	<AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab1ACTCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 14:02:13 -0500
In-Reply-To: <AANLkTiki5ZePtdj4ni2++z1KvHOttev1ZciaV-bRFbWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 3 Jan 2011 10:47:20 -0800

> I'm not sure why this would be needed.  What is the a advantage in
> making the TX and RX queues match?

That's how their hardware based RFS essentially works.

Instead of watching for "I/O system calls" like we do in software, the
chip watches for which TX queue a flow ends up on and matches things
up on the receive side with the same numbered RX queue to match.
