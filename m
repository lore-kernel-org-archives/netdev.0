From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 17:10:40 -0700 (PDT)
Message-ID: <20071005.171040.43864052.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<200710051846.19965.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: netdev@axxeo.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753242AbXJFAKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 20:10:41 -0400
In-Reply-To: <200710051846.19965.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Oeser <netdev@axxeo.de>
Date: Fri, 5 Oct 2007 18:46:19 +0200

> > +static int niu_num_alt_addr(struct niu *np)
> static int niu_num_alt_addr(const struct niu *np)

There are a lot of functions that can be modified to take
a const "struct niu *" argument, if I find some time I'll
go over the entire driver and make this transformation.

Thanks.
