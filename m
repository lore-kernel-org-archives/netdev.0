From: David Miller <davem@davemloft.net>
Subject: Re: Patch "[PKT_SCHED]: PSCHED_TADD() and PSCHED_TADD2() can
 result,tv_usec >= 1000000" seems wrong
Date: Sun, 23 Jul 2006 23:37:34 -0700 (PDT)
Message-ID: <20060723.233734.93384804.davem@davemloft.net>
References: <44B7A76C.4010703@yahoo.fr>
	<44BDE3F7.4000507@necst.nec.co.jp>
	<44BE29E6.1060602@yahoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maeda-sxb@necst.nec.co.jp, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23700
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751232AbWGXGh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 02:37:27 -0400
To: guichaz@yahoo.fr
In-Reply-To: <44BE29E6.1060602@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Chazarain <guichaz@yahoo.fr>
Date: Wed, 19 Jul 2006 14:47:34 +0200

> Shuya MAEDA wrote :
> > "while (__delta > USEC_PER_SEC){ ... }", but I think it should be
> > "while (__delta >= USEC_PER_SEC){ ... }". Is it right?
> 
> I agree, good catch :-)

Applied, thanks a lot.
