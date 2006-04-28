From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 11:20:16 -0700 (PDT)
Message-ID: <20060428.112016.43203625.davem@davemloft.net>
References: <20060428061054.GD17360@2ka.mipt.ru>
	<20060428.002027.51369887.davem@davemloft.net>
	<20060428073216.GB3378@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59557
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751787AbWD1SdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 14:33:23 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428073216.GB3378@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 11:32:16 +0400

> Definitely, userspace application must be very smart to deal with 
> ip/tcp/option headers...

That is why we will put an "offset+len" in the ring so they need not
parse the packet headers.
