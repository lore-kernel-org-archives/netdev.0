From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Sun, 30 Jul 2006 15:30:04 -0700 (PDT)
Message-ID: <20060730.153004.45876935.davem@davemloft.net>
References: <m3zmevqhgn.fsf@defiant.localdomain>
	<20060727164334.GA2779@ms2.inr.ac.ru>
	<m3fygjkpwb.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48015
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751427AbWG3W3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 18:29:53 -0400
To: khc@pm.waw.pl
In-Reply-To: <m3fygjkpwb.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 30 Jul 2006 18:40:04 +0200

> Do the semantics (I'm not talking about bugs) allow skb passed
> to dev->hard_header() (if defined) and then to dev->hard_start_xmit()
> to have less link layer header space than dev->hard_header_len?
> 
> I.e., is dev->hard_header_len only advisory?

It does seem weird that IP output won't pay attention to
dev->hard_header_len if the device does not provide a
dev->hard_header() method.  That is for sure.
