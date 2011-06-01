From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Tue, 31 May 2011 23:35:11 -0700 (PDT)
Message-ID: <20110531.233511.302250532.davem@davemloft.net>
References: <1306828745.7481.660.camel@pasglop>
	<20110531.194115.486383514.davem@davemloft.net>
	<1306909465.29297.17.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ruediger.herbst@googlemail.com,
	bhamilton04@gmail.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668Ab1FAGfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 02:35:20 -0400
In-Reply-To: <1306909465.29297.17.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 01 Jun 2011 16:24:25 +1000

> In any case, I now simplified the driver even more, removing the private
> lock and the mutex as well. So I'm really ready to trade those 1.5% loss
> on 7 years old HW for a simpler and more maintainable driver, if you are
> ok with that. It still needs testing on sparc tho.

I am :-)

> I'll post a new spin later today after I've tested suspend/resume again.

Ok.
