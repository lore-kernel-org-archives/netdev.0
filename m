From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert usage of packet_type to read_mostly
Date: Tue, 10 Mar 2009 05:24:40 -0700 (PDT)
Message-ID: <20090310.052440.142393908.davem@davemloft.net>
References: <20090309111829.297ead22@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35873
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbZCJMYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:24:55 -0400
In-Reply-To: <20090309111829.297ead22@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 9 Mar 2009 11:18:29 -0700

> Protocols that use packet_type can be __read_mostly section for better
> locality. Elminate any unnecessary initializations of NULL.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
