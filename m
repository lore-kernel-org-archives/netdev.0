From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next 5/8] ipv6: Check return of dev_set_allmulti
Date: Tue, 24 Jun 2008 12:52:43 +0900 (JST)
Message-ID: <20080624.125243.112730755.yoshfuji@linux-ipv6.org>
References: <485AFFFB.5040901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60197 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbYFXDvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 23:51:48 -0400
In-Reply-To: <485AFFFB.5040901@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <485AFFFB.5040901@cn.fujitsu.com> (at Fri, 20 Jun 2008 08:55:23 +0800), Wang Chen <wangchen@cn.fujitsu.com> says:

> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

The comment is too obvious to have.

--yoshfuji
