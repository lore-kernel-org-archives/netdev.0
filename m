From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take2][NET] ifb: set separate lockdep classes for queue
 locks
Date: Thu, 20 Mar 2008 17:05:45 -0700 (PDT)
Message-ID: <20080320.170545.77998979.davem@davemloft.net>
References: <20080319073441.GA3918@ff.dom.local>
	<20080320.153745.232982215.davem@davemloft.net>
	<20080321000312.GA7755@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, denys@visp.net.lb, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751381AbYCUAF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 20:05:29 -0400
In-Reply-To: <20080321000312.GA7755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 21 Mar 2008 01:03:12 +0100

> IMHO it wastes a bit of memory when lockdep is off and adds some
> overhead when lockdep is "partialy" on and doesn't need this, but
> it's really late...

Understood but I really think this is the right way to
implement this.

Patch applied, thanks!
