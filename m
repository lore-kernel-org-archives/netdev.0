From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix possible null pointer dereference in ehea_qmr.c
Date: Mon, 14 Mar 2011 15:34:56 -0700 (PDT)
Message-ID: <20110314.153456.52185310.davem@davemloft.net>
References: <1300088764-9330-1-git-send-email-huzaifas@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leitao@linux.vnet.ibm.com
To: huzaifas@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36310
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753915Ab1CNWeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:34:18 -0400
In-Reply-To: <1300088764-9330-1-git-send-email-huzaifas@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huzaifas@redhat.com
Date: Mon, 14 Mar 2011 13:16:04 +0530

> From: Huzaifa Sidhpurwala <huzaifas@redhat.com>
> 
> If queue is zero, dont reference it
> 
> Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>

There is no code path where hw_queue_dtor() is called with a NULL
"queue".  I've checked all of the code paths.

Therefore it's better to simply remove the NULL check.
