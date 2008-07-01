From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v2 [PATCH net-next 1/8] af_packet: Check return of dev_set_promiscuity/allmulti
Date: Tue, 01 Jul 2008 11:31:14 +0800
Message-ID: <4869A502.90506@cn.fujitsu.com>
References: <4869A251.108@cn.fujitsu.com> <4869A2D5.1010605@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60698 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751724AbYGADfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2008 23:35:44 -0400
In-Reply-To: <4869A2D5.1010605@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen said the following on 2008-7-1 11:21:
> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> In af_packet, we check all positive increment for promiscuity and allmulti
> to get error return.
> 

oops, the subject should be 1/7.
sorry :(

