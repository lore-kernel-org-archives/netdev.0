From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 20:50:44 -0700 (PDT)
Message-ID: <20061018.205044.68042074.davem@davemloft.net>
References: <200610181055.32102.dada1@cosmosbay.com>
	<20061018124202.GA31981@fogou.chygwyn.com>
	<200610181532.22979.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@chygwyn.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:10667
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423249AbWJSDug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:50:36 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610181532.22979.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Oct 2006 15:32:22 +0200

> OK then. Even on a distro kernel (allyesconfig), size(flow) would
> shrink by 20 bytes.

For the time being, why don't we just kill off the unused dnports
bits entirely.

Once the support code to use those bits is written, we can
investigate intelligent ways to pack them back into struct
flow, ok?
