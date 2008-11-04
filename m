From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: '&' redux
Date: Mon, 03 Nov 2008 18:21:49 -0800 (PST)
Message-ID: <20081103.182149.156430442.davem@davemloft.net>
References: <20081104022200.GA15822@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33641
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbYKDCWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 21:22:14 -0500
In-Reply-To: <20081104022200.GA15822@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 4 Nov 2008 05:22:00 +0300

> I want to compile out proc_* and sysctl_* handlers totally and
> stub them to NULL depending on config options, however usage of &
> will prevent this, since taking adress of NULL pointer will break
> compilation.
> 
> So, drop & in front of every ->proc_handler and every ->strategy
> handler, it was never needed in fact.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.

Using '&' when referring to functions is a pet peeve of mine :)
