From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [NET]: Fix whitespace errors
Date: Sat, 10 Feb 2007 01:24:04 +0900 (JST)
Message-ID: <20070210.012404.121782477.yoshfuji@linux-ipv6.org>
References: <20070209.234154.22788645.yoshfuji@linux-ipv6.org>
	<F29DCCE2-0FF6-4B9A-BA07-2D812BF4B320@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, akpm@osdl.org,
	yoshfuji@linux-ipv6.org
To: galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54400 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946609AbXBIQYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 11:24:06 -0500
In-Reply-To: <F29DCCE2-0FF6-4B9A-BA07-2D812BF4B320@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <F29DCCE2-0FF6-4B9A-BA07-2D812BF4B320@kernel.crashing.org> (at Fri, 9 Feb 2007 09:47:27 -0600), Kumar Gala <galak@kernel.crashing.org> says:

> > to fix trivial whitespace errors:
> >  - convert leading sequences of whitespace with tab(s).
> >  - remove whitespace at the end of line.
> > under net.
> >
> > Tree is on top of current net-2.6 tree.
> 
> Do you have a script that did this?

----->8-----
#!/bin/sh

TEMP=$(mktemp -t spacecheck.XXXXXX)
unexpand $1 | sed -e 's/[[:space:]][[:space:]]*$//' > ${TEMP}
cat ${TEMP} > $1
rm ${TEMP}
----->8-----

Then, "git-reset" and "git-commit".

--yoshfuji
