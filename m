From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: fix kernel panic from no dev->hard_header_len
 space
Date: Tue, 01 Aug 2006 17:38:43 -0700 (PDT)
Message-ID: <20060801.173843.35018003.davem@davemloft.net>
References: <m3bqr5z0ah.fsf@defiant.localdomain>
	<20060801195431.GA29335@ms2.inr.ac.ru>
	<m37j1sc7ck.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:48310
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750855AbWHBAij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:38:39 -0400
To: khc@pm.waw.pl
In-Reply-To: <m37j1sc7ck.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Wed, 02 Aug 2006 02:24:43 +0200

> Do you mean IP calls hard_header() which, in turn, does skb_push()?
> 
> How about Ethernet - is it safe? There is hard_header() which blindly
> adds 14 bytes.

I think Alexey is saying that setting ->hard_header() creates an
agreement between the device and IP that IP will make sure
that dev->hard_header_len bytes are available in the header
area.

