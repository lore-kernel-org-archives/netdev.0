From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 2/2] macvtap: Implement multiqueue macvtap driver
Date: Mon, 2 Aug 2010 18:34:26 +0200
Message-ID: <201008021834.26688.arnd@arndb.de>
References: <20100802143304.1517.42494.sendpatchset@krkumar2.in.ibm.com> <201008021752.28475.arnd@arndb.de> <OFE0F15F8D.2C34C2AD-ON65257773.00579311-65257773.005A60A9@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, davem@davemloft.net, mst@redhat.com,
	netdev@vger.kernel.org, therbert@google.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49658 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750959Ab0HBQe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 12:34:29 -0400
In-Reply-To: <OFE0F15F8D.2C34C2AD-ON65257773.00579311-65257773.005A60A9@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 02 August 2010, Krishna Kumar2 wrote:
> "include/linux/if_macvlan.h:57: error: braced-group within expression
>         allowed only inside a function"
> Please let me know if there is any alternative (curly braces cannot be
> used outside of functions). Otherwise one change required is to add:
> 
> #ifndef MIN
> #endif
> 
> I will wait for a few hours and resubmit the patches.

Maybe just open-code the minimum computation:

#define MAX_MACVTAP_QUEUES   (NR_CPUS < 16 ? NR_CPUS : 16)

	ARnd
