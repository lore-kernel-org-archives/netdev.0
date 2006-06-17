From: David Miller <davem@davemloft.net>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 19:51:47 -0700 (PDT)
Message-ID: <20060616.195147.123399792.davem@davemloft.net>
References: <1150494161.26368.39.camel@rh4>
	<87bqsslk9e.fsf@blackdown.de>
	<1150507652.26368.46.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jk@blackdown.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10665
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751226AbWFQCvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 22:51:24 -0400
To: mchan@broadcom.com
In-Reply-To: <1150507652.26368.46.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 Jun 2006 18:27:32 -0700

> In the meantime, I wonder if we should disable TSO by default on the
> 5780 chip for 2.6.17.

Sounds reasonable.  Would we disable it for all chips that set
TG3_FLG2_5780_CLASS or a specific variant?
