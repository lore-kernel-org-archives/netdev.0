From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Fix a potential crash during shutdown.
Date: Wed, 06 Apr 2011 12:40:31 -0700 (PDT)
Message-ID: <20110406.124031.260096804.davem@davemloft.net>
References: <20110406155313.GA2246@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57355
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754753Ab1DFTlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:41:08 -0400
In-Reply-To: <20110406155313.GA2246@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Wed, 6 Apr 2011 10:53:13 -0500

> adapter could remain uninitialized if probe fails for some reason.
> A null pointer access could cause a crash if be_shutdown
> is called after that.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied to net-2.6, thank you.
