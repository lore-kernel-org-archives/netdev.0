From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Missing csum_fold() in ip6t_HL.c ?
Date: Mon, 12 Feb 2007 23:47:21 +0900 (JST)
Message-ID: <20070212.234721.90984848.yoshfuji@linux-ipv6.org>
References: <20060915103755.GB5286@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	yoshfuji@linux-ipv6.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54460 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964949AbXBLOrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 09:47:21 -0500
In-Reply-To: <20060915103755.GB5286@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060915103755.GB5286@martell.zuzino.mipt.ru> (at Fri, 15 Sep 2006 14:37:56 +0400), Alexey Dobriyan <adobriyan@gmail.com> says:

> It looks like "diffs" array is write-only. It also looks like ipv4
> occurences use some csum_fold() trickery. Was is forgotten here? Should
> "diffs" be removed?

Since we do not have checksum in IPv6 header, we do not need to
adjust checksum when we touch hoplimit.

So, just removing it should be safe.

--yoshfuji
