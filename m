From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 22/44] [IPV6]: Find option offset by type.
Date: Thu, 24 Aug 2006 05:26:22 +0900 (JST)
Message-ID: <20060824.052622.09867712.yoshfuji@linux-ipv6.org>
References: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
	<44EC8EBE.9080701@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33288 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965153AbWHWUYe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 16:24:34 -0400
To: brian.haley@hp.com
In-Reply-To: <44EC8EBE.9080701@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <44EC8EBE.9080701@hp.com> (at Wed, 23 Aug 2006 13:22:06 -0400), Brian Haley <brian.haley@hp.com> says:

> > +	/* not_found */
> > +	return -1;
> > + bad:
> > +	return -1;
> > +}
> 
> You could change this to:
> 
> 	/* not_found */
>     bad:
> 	return -1;
>     }

Right.  I think our compiler is smart enough to eliminate that though.
(Similar clean-up will be done for ipv6_rearrange_destopt() as well.)

--yoshfuji
