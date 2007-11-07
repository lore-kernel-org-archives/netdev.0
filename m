From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Clean proto_(un)register from in-code ifdefs
Date: Wed, 07 Nov 2007 02:23:48 -0800 (PST)
Message-ID: <20071107.022348.103221163.davem@davemloft.net>
References: <4730A258.2060304@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbXKGKXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:23:48 -0500
In-Reply-To: <4730A258.2060304@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 06 Nov 2007 20:20:24 +0300

> The struct proto has the per-cpu "inuse" counter, which is handled
> with a special care. All the handling code hides under the ifdef 
> CONFIG_SMP and it introduces some code duplication and makes it 
> look worse than it could.
> 
> Clean this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
