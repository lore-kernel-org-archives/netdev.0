From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 22:09:34 -0700 (PDT)
Message-ID: <20060605.220934.90119221.davem@davemloft.net>
References: <adalksanb0c.fsf@cisco.com>
	<20060605.215821.69020274.davem@davemloft.net>
	<adad5dmnacd.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mchan@broadcom.com, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37039
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932107AbWFFFJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 01:09:35 -0400
To: rdreier@cisco.com
In-Reply-To: <adad5dmnacd.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 05 Jun 2006 22:04:34 -0700

> Am I right in thinking that dev->xmit_lock still serializes mc_list
> operations, even for LLTX drivers?

Correct.
