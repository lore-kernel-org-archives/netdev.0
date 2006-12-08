From: David Miller <davem@davemloft.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 07 Dec 2006 23:52:05 -0800 (PST)
Message-ID: <20061207.235205.102574126.davem@davemloft.net>
References: <20061207.022010.120465413.davem@davemloft.net>
	<20061207102257.GC19479@gate.ebshome.net>
	<1165488962.5027.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebs@ebshome.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1425072AbWLHHvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 02:51:51 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1165488962.5027.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 07 Dec 2006 21:56:02 +1100

> Dave, the main point of my initial email was: should we provide a
> routine from the net core to initialize such dummy devices properly ?
> I'm a little worried that some day, the NAPI code will change and the
> initialisations done by the driver will not be enough anymore...

That sounds like an excellent idea.

Once you guys have your implementation sorted out, submit
a patch proposing the generic bits and we'll review it.

Thanks.
