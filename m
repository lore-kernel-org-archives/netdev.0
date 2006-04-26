From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 15:35:07 -0700 (PDT)
Message-ID: <20060426.153507.26039041.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AE7F@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, kelly@au1.ibm.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21434
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932421AbWDZWfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 18:35:33 -0400
To: caitlinb@broadcom.com
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AE7F@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Caitlin Bestler" <caitlinb@broadcom.com>
Date: Wed, 26 Apr 2006 13:20:50 -0700

> If you are dropping all packets from IP X, then how was the connection
> established? Obviously we are only dealing with connections that
> were established before the rule to drop all packets from IP X
> was created.

The problem is listening TCP connections that you don't
want anyone in the world to be able to connect to.
