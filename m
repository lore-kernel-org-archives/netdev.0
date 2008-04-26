From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 22:33:28 -0700 (PDT)
Message-ID: <20080425.223328.219660064.davem@davemloft.net>
References: <20080425.162417.25756786.yoshfuji@linux-ipv6.org>
	<OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com>
	<20080426.141454.105085673.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56078
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751722AbYDZFd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 01:33:29 -0400
In-Reply-To: <20080426.141454.105085673.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sat, 26 Apr 2008 14:14:54 +0900 (JST)

> In article <OFAF2C4F7A.77CF5A8D-ON88257437.0001566B-88257437.00023C8D@us.ibm.com> (at Fri, 25 Apr 2008 18:24:28 -0600), David Stevens <dlstevens@us.ibm.com> says:
> 
> > +       }
> > +       if (level == SOL_IPV6)
> > +               return ipv6_setsockopt(sock, level, optname, koptval, 
> > koptlen);
> > +       return ip_setsockopt(sock, level, optname, koptval, koptlen);
> > +}
> > +
> 
> Sorry, you cannot do this.  Build with allmodconfig.

Indeed, that will not work.
