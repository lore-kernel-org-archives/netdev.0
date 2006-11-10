From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] rules: Remove bogus tos validation check
Date: Fri, 10 Nov 2006 14:11:14 -0800 (PST)
Message-ID: <20061110.141114.112624317.davem@davemloft.net>
References: <20061110122838.GI8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19390
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966124AbWKJWLN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:11:13 -0500
To: tgraf@suug.ch
In-Reply-To: <20061110122838.GI8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 10 Nov 2006 13:28:38 +0100

> Noticed by Al Viro:
>      (frh->tos & ~IPV6_FLOWINFO_MASK))
> where IPV6_FLOWINFO_MASK is htonl(0xfffffff) and frh->tos
> is u8, which makes no sense here...
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks a lot.
