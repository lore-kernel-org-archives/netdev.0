From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Sat, 26 Apr 2008 14:14:54 +0900 (JST)
Message-ID: <20080426.141454.105085673.yoshfuji@linux-ipv6.org>
References: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
	<OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33775 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbYDZFO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:14:56 -0400
In-Reply-To: <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com> (at Fri, 25 Apr 2008 18:24:28 -0600), David Stevens <dlstevens@us.ibm.com> says:

> +       }
> +       if (level == SOL_IPV6)
> +               return ipv6_setsockopt(sock, level, optname, koptval, 
> koptlen);
> +       return ip_setsockopt(sock, level, optname, koptval, koptlen);
> +}
> +

Sorry, you cannot do this.  Build with allmodconfig.

--yoshfuji
