From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 18:44:10 -0700 (PDT)
Message-ID: <20090909.184410.64382338.davem@davemloft.net>
References: <4AA84FE3.6030407@sun.com>
	<20090909.181033.25374239.davem@davemloft.net>
	<4AA85404.5020300@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joyce.Yu@Sun.COM, netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36805
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754869AbZIJBny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:43:54 -0400
In-Reply-To: <4AA85404.5020300@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Wed, 09 Sep 2009 18:19:00 -0700

> We can work on a version which implements HW header checking and do
> pullup accordingly.

I think using a constant based on the vlan header size would be
sufficient to fix this.
