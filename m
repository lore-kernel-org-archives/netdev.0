From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: add driver hooks for time stamping.
Date: Mon, 05 Jul 2010 19:03:01 -0700 (PDT)
Message-ID: <20100705.190301.48512969.davem@davemloft.net>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<a9c79dd7d996a352b37ea4e650b235d0c8b996d1.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993Ab0GFCCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:02:48 -0400
In-Reply-To: <a9c79dd7d996a352b37ea4e650b235d0c8b996d1.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 5 Jul 2010 07:31:07 +0200

> This patch adds hooks for transmit and receive time stamps. The
> transmit hook allows a software fallback for transmit time stamps,
> for MACs lacking time stamping hardware. The receive hook does not yet
> have any effect, but it prepares the way for hardware time stamping
> in PHY devices. Using the hooks will still require adding two inline
> function calls to each MAC driver.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Applied.
