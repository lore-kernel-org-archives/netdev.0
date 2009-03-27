From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Add missing include into include/linux/netdevice.h
Date: Fri, 27 Mar 2009 15:55:45 -0700 (PDT)
Message-ID: <20090327.155545.238803642.davem@davemloft.net>
References: <1238150213-30416-1-git-send-email-dmitri.vorobiev@movial.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dmitri.vorobiev@movial.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752597AbZC0Wz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 18:55:57 -0400
In-Reply-To: <1238150213-30416-1-git-send-email-dmitri.vorobiev@movial.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitri Vorobiev <dmitri.vorobiev@movial.com>
Date: Fri, 27 Mar 2009 12:36:53 +0200

> The inline function skb_gro_mac_header defined in include/linux/netdevice.h
> makes use of page_address(). Depending on configuration options, the latter
> is either defined as a macro or is declared as a function in another header
> file, namely include/linux/mm.h. However, include/linux/netdevice.h does not
> include include/linux/mm.h.
> 
> On MIPS, this has produced the following build error:

Applied, thanks.
