From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [PATCH] [XFRM] Add CONFIG_INET dependency to CONFIG_XFRM_STATISTICS
Date: Sat, 16 Feb 2008 11:20:39 +0900
Message-ID: <200802161120.39739.nakam@linux-ipv6.org>
References: <1203088123.29269.1.camel@localhost> <20080215.152400.65001698.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: johfel@gmx.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:44975 "EHLO mail.gomagoma.org"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756122AbYBPCvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 21:51:37 -0500
In-Reply-To: <20080215.152400.65001698.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Saturday 16 February 2008 08:24, David Miller wrote:
> From: Johann Felix Soden <johfel@gmx.de>
> Date: Fri, 15 Feb 2008 16:08:43 +0100
> 
> > From: Johann Felix Soden <johfel@users.sourceforge.net>
> > 
> > With INET=n and XFRM_STATISTICS=y I get the following build failure:
> > 
> > net/built-in.o: In function `xfrm_init':
> > (.init.text+0xcd7): undefined reference to `snmp_mib_init'
> > 
> > Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
> > CC: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> A fix for this has been in my net-2.6 tree for a few days,
> and Linus pulled it in this morning.

Thank you guys for taking care of it.

-- 
Masahide NAKAMURA
