From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 17:07:12 -0700 (PDT)
Message-ID: <20060929.170712.70217638.davem@davemloft.net>
References: <1159564053.3741.19.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16267
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422837AbWI3AHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 20:07:09 -0400
To: mchan@broadcom.com
In-Reply-To: <1159564053.3741.19.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 29 Sep 2006 14:07:32 -0700

> [BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present.

Applied thanks.

We can back this out if we come up with a sceme to do this
at a generic level, or we find other faults in this AMD
chipset such that added together it warrants a full MSI
disable.

