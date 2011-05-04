From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/bonding: bonding: Adjust coding style for bond_3ad
 files.
Date: Wed, 4 May 2011 16:38:03 -0700
Message-ID: <20110504163803.57cde72e@nehalam>
References: <20110504221844.GA17955@x61.tchesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors.vger.kernel.org@x61.tchesoft.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Rafael Azenha Aquini <aquini@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51625 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab1EDXiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 19:38:09 -0400
In-Reply-To: <20110504221844.GA17955@x61.tchesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 May 2011 19:18:47 -0300
Rafael Azenha Aquini <aquini@linux.com> wrote:

>  
> -// compare MAC addresses
>  #define MAC_ADDRESS_COMPARE(A, B) memcmp(A, B, ETH_ALEN)
>  
>  static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };

These should be changed to use compare_ether_addr and is_zero_ether_addr
routines in etherdevice.h

-- 
