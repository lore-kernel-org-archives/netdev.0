From: David Miller <davem@davemloft.net>
Subject: Re: UDP Out 0f Sequence
Date: Wed, 20 Sep 2006 20:51:16 -0700 (PDT)
Message-ID: <20060920.205116.71097065.davem@davemloft.net>
References: <F444CAE5E62A714C9F45AA292785BED30EB97599@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62397
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751182AbWIUDvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 23:51:06 -0400
To: rajib.majumder@credit-suisse.com
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB97599@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Date: Thu, 21 Sep 2006 10:50:17 +0800

> Does this mean if we have 2 hosts connected back to back (there's no
> network device in between), sequence is guaranteed even in UDP?

Not true.  Even for back to back systems SMP can cause packets
to be delivered out of order even locally within the system
on receive.
