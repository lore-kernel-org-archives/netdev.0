From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netxen: fix firmware init handshake
Date: Tue, 23 Jun 2009 04:21:21 -0700 (PDT)
Message-ID: <20090623.042121.62955717.davem@davemloft.net>
References: <1245738381-30163-1-git-send-email-dhananjay@netxen.com>
	<1245738381-30163-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37431
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756036AbZFWLVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 07:21:17 -0400
In-Reply-To: <1245738381-30163-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Mon, 22 Jun 2009 23:26:21 -0700

> Make sure all functions run firmware init handshake.
> 
> If PCI function 0 fails to initialize firmware, mark the
> state failed so that other functions on the same board
> bail out quickly instead of waiting 30s for firmware
> handshake.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
