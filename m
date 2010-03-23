From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add additional lock to qdisc to increase
 enqueue/dequeue fairness
Date: Tue, 23 Mar 2010 13:31:24 -0700 (PDT)
Message-ID: <20100323.133124.139557595.davem@davemloft.net>
References: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753081Ab0CWUbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 16:31:01 -0400
In-Reply-To: <20100323202553.21598.10754.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 23 Mar 2010 13:25:53 -0700

> The qdisc layer shows a significant issue when you start transmitting from
> multiple CPUs.

Why are you hitting any central qdisc lock on a multiqueue
configuration?
