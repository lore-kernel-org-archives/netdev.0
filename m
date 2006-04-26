From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 26 Apr 2006 15:59:37 -0700 (PDT)
Message-ID: <20060426.155937.69145445.davem@davemloft.net>
References: <54AD0F12E08D1541B826BE97C98F99F143AEC1@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, kelly@au1.ibm.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41177
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964886AbWDZXAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 19:00:17 -0400
To: caitlinb@broadcom.com
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F143AEC1@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Caitlin Bestler" <caitlinb@broadcom.com>
Date: Wed, 26 Apr 2006 15:53:44 -0700

> The netchannel qualifiers should only deal with TCP packets
> for established connections. Listens would continue to be 
> dealt with by the existing stack logic, vj_channelizing
> only occurring when the the connection was accepted.

I consider netchannel support for listening TCP sockets
to be absolutely essential.
