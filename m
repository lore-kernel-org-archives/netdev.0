From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Mon, 31 Mar 2008 13:07:57 -0700 (PDT)
Message-ID: <20080331.130757.199769025.davem@davemloft.net>
References: <47EAAFEC.6000805@trash.net>
	<20080331123311.64e4ca37@extreme>
	<47F13E43.2040404@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbYCaUH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 16:07:57 -0400
In-Reply-To: <47F13E43.2040404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 31 Mar 2008 21:40:51 +0200

> Thanks. It seems it parses only top-level attributes, which
> is probably why you didn't need the nlattr_find command I
> used in my patch. The problem with this is that finding and
> parsing nested attributes using the existing BPF commands is
> complicated since you need to fully parse netlink headers
> and walk through them. You can't even reuse that part for
> multiple nested attributes since you can't jump backwards.
> So I think it would be preferrable to have a simpler method
> for this.

Agreed.
