From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix possible null pointer dereference in
 davinci_cpdma.c
Date: Mon, 14 Mar 2011 15:36:16 -0700 (PDT)
Message-ID: <20110314.153616.13749823.davem@davemloft.net>
References: <1300091954-10367-1-git-send-email-huzaifas@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khilman@deeprootsystems.com, cyril@ti.com
To: huzaifas@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36316
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915Ab1CNWfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:35:38 -0400
In-Reply-To: <1300091954-10367-1-git-send-email-huzaifas@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huzaifas@redhat.com
Date: Mon, 14 Mar 2011 14:09:14 +0530

> From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
> 
> Check if chan exists before dereferencing it
> 
> Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>

Just like your EHEA driver patch, this situation is such that
cpdma_chan_destroy() is never called with a NULL "chan" argument.

Therefore it's better to simply remove the NULL check.
