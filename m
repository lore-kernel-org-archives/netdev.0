From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH 1/1] r8169: fix RxMissed register access
Date: Thu, 11 Sep 2008 09:44:22 +0200
Message-ID: <48C8CC56.5010802@redhat.com>
References: <20080910202856.GA22884@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Adam Huffman <bloch@verdurin.com>,
	Hermann Gausterer <kernel-bug-tracker@mrq1.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53842 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbYIKHxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2008 03:53:07 -0400
In-Reply-To: <20080910202856.GA22884@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> - the register is defined for the 8169 chipset only and there is
>   no 8169 beyond RTL_GIGA_MAC_VER_06.
> - only the lower 3 bytes of the register are valid
> 
> Fixes:
> 1. http://bugzilla.kernel.org/show_bug.cgi?id=10180
> 2. http://bugzilla.kernel.org/show_bug.cgi?id=11062 (bits of)
> 
> Tested by Hermann Gausterer and Adam Huffman.
I can confirm it works great for my RTL8102el and RTL8168b.

Ivan

> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
