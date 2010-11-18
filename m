From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] CAIF: Fix U5500 compile error for shared
 memory driver
Date: Thu, 18 Nov 2010 09:29:38 -0800 (PST)
Message-ID: <20101118.092938.189700640.davem@davemloft.net>
References: <1290076936-1946-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kim.xx.lilliestierna@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755182Ab0KRR3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 12:29:13 -0500
In-Reply-To: <1290076936-1946-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Date: Thu, 18 Nov 2010 11:42:16 +0100

> From: Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>
> 
> Rearrange pr_fmt as __func__ is a variable and not a constant

Just remove the __func__ thing, it's just noise.

Also, you didn't include a proper "Signed-off-by: " tag in your
commit message.
