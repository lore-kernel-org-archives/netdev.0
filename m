From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/1] r8169: enforce RX_MULTI_EN for the 8168f.
Date: Thu, 12 Sep 2013 01:15:43 +0200
Message-ID: <20130911231543.GA29725@electric-eye.fr.zoreil.com>
References: <20130907231535.GB24530@electric-eye.fr.zoreil.com>
 <522C391A.3020408@redhat.com>
 <20130911.161606.1575635427616463157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, netdev@vger.kernel.org, david@unsolicited.net,
	fredo@starox.org, hayeswang@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34632 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757528Ab3IKXQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 19:16:03 -0400
Content-Disposition: inline
In-Reply-To: <20130911.161606.1575635427616463157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> Francois, if you reply to this thread with your signoff, all will
> be well and I will apply this.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

I slowly built an AMD IOMMU + 8168{e/f} problem report pattern but
the picture got blurred:
- Hayes has not heard of anything like this
- the oracle suggests it could be an "AMD IOMMU + whatever" problem
- "iommu=pt" seems quite effective (hardly surprizing :o/ )

I still have a pile of iommu mailing-list messages to search through.
Let aside the AMD-Vi error log message, I haven't done a thorough analysis.

It's lame.

-- 
Ueimor
