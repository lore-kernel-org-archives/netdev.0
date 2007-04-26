From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 source routing patch is still broken?
Date: Fri, 27 Apr 2007 08:52:10 +0900 (JST)
Message-ID: <20070427.085210.117150909.yoshfuji@linux-ipv6.org>
References: <46311F76.9040803@redhat.com>
	<20070426.150434.91313967.davem@davemloft.net>
	<46313180.6040809@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33194 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbXDZXwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 19:52:12 -0400
In-Reply-To: <46313180.6040809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <46313180.6040809@redhat.com> (at Thu, 26 Apr 2007 19:10:56 -0400), Chuck Ebbert <cebbert@redhat.com> says:

> Another question: is it a good idea to even be shipping release
> kernels with Mobile IPV6 enabled? Unfortunately, "experimental"
> isn't enough to go by...

Well, we have still 2 missing pieces in 2.6.21, and we are trying to
push them (source address selection, which is already in net-2.6 and
xfrm subpolicy, which is still on dave's backlog?) to 2.6.22.
After 2.6.23, we would say yes.

--yoshfuji
