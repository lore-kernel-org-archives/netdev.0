From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:09:54 -0700 (PDT)
Message-ID: <20060428.120954.92405760.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143B0E2@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060428161221.GA12357@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, kelly@au1.ibm.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18317
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751797AbWD1TLL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:11:11 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428161221.GA12357@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 20:12:21 +0400

> If there is dataflow, not flow of packets or flow of data with holes,
> it could be possible to modify recv() to just return the right pointer,
> so in theory userspace modifications would be minimal.
> With copy in place it completely does not differ from current design
> with copy_to_user() being used since memcpy() is just slightly faster
> than copy*user().

I very much feel that avoiding userland API changes is
a complete mistake.

We need new interfaces to do this right.
