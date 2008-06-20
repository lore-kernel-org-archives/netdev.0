From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: /proc/net/tcp rto,ato values not scaled properly
Date: Fri, 20 Jun 2008 12:05:26 -0700 (PDT)
Message-ID: <20080620.120526.246965779.davem@davemloft.net>
References: <20080620115603.5c494cab@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752542AbYFTTF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 15:05:26 -0400
In-Reply-To: <20080620115603.5c494cab@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 20 Jun 2008 11:56:03 -0700

> I found another case where we are sending information to userspace
> in the wrong HZ scale.  This should have been fixed back in 2.5 :-(
> 
> This means an ABI change but as it stands there is no way for an application
> like ss to get the right value.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Agree with your patch, but 'ss' should be getting this kind of info
from netlink not procfs, right?

