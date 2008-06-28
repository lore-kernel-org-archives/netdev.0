From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly
 (v2)
Date: Fri, 27 Jun 2008 20:00:29 -0700 (PDT)
Message-ID: <20080627.200029.18573744.davem@davemloft.net>
References: <20080620115603.5c494cab@extreme>
	<20080623111600.2324b7ff@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752186AbYF1DA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:00:29 -0400
In-Reply-To: <20080623111600.2324b7ff@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 23 Jun 2008 11:16:00 -0700

> I found another case where we are sending information to userspace
> in the wrong HZ scale.  This should have been fixed back in 2.5 :-(
> 
> This means an ABI change but as it stands there is no way for an application
> like ss to get the right value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
