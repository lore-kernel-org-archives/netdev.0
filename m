From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] ethoc: fix typo to compute number of tx descriptors
Date: Wed, 07 Oct 2009 03:41:58 -0700 (PDT)
Message-ID: <20091007.034158.122372093.davem@davemloft.net>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45415
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758241AbZJGKmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:42:03 -0400
In-Reply-To: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Chou <thomas@wytron.com.tw>
Date: Mon,  5 Oct 2009 17:33:17 +0800

> It should be max() instead of min(). Use 1/4 of available
> descriptors for tx, and there should be at least 2 tx
> descriptors.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>

Applied.
