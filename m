From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: provide capability and group sets via SCM
Date: Mon, 14 Feb 2011 17:49:19 -0800 (PST)
Message-ID: <20110214.174919.48492611.davem@davemloft.net>
References: <4D3466BD.10500@schaufler-ca.com>
	<4D51C38B.1060902@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ext-jarkko.2.sakkinen@nokia.com, Janne.Karhunen@nokia.com,
	elena.reshetova@nokia.com
To: casey@schaufler-ca.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52782
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752620Ab1BOBsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 20:48:43 -0500
In-Reply-To: <4D51C38B.1060902@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Schaufler <casey@schaufler-ca.com>
Date: Tue, 08 Feb 2011 14:28:27 -0800

> 
> Subject: [PATCH] net: provide group lists and capability set via CMSG
> 
> Provide the namespace converted group list of the peer
> process using the SCM mechanism. Provide the capability
> set of the peer process. The capability set is not
> namespace converted on the assumption that there is no
> such conversion available or required.
> 
> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>

You can't just hit the asm-generic header, you have to also hit
all of the architectures that don't use the asm-generic header,
including sparc, powerpc, mips, s390, arm, alpha, cris, frv, h8300,
ia64, m32r, m68k, m68knommu, mn10300, parisc, and xtensa.
