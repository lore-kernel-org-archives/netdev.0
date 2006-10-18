From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Tue, 17 Oct 2006 23:53:36 -0700 (PDT)
Message-ID: <20061017.235336.30182405.davem@davemloft.net>
References: <4535B6B7.4070107@cosmosbay.com>
	<20061017.222709.130237201.davem@davemloft.net>
	<4535BEB9.3010400@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8844
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964792AbWJRGxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 02:53:30 -0400
To: dada1@cosmosbay.com
In-Reply-To: <4535BEB9.3010400@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Oct 2006 07:42:17 +0200

> How many people are using DECNET and want to pay the price of this
> 20 bytes dnports structure ?

I bet you could make that cost get hidden by careful rearrangement
of the struct flow, or adjustment of the implementation.

BTW, I see assignments to these fields, and as a specific example
uli_u.dnports.objnamel but no use of it.  Perhaps much of dnports can
even be deleted outright. :-)
