From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7] qlge: bugfix: Add missing put_page() call.
Date: Thu, 12 Feb 2009 16:38:52 -0800 (PST)
Message-ID: <20090212.163852.12244009.davem@davemloft.net>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
	<1234360717-32194-3-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754327AbZBMAi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:38:58 -0500
In-Reply-To: <1234360717-32194-3-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 11 Feb 2009 05:58:33 -0800

> We put the page back if we can't get mapping for it.  We don't
> want unmapped buffers on our receive buffer queue.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Applied.
