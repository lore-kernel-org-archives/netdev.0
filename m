From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [UDPv6] Possible dst leak in udpv6_sendmsg.
Date: Tue, 03 Jun 2008 20:35:32 +0900 (JST)
Message-ID: <20080603.203532.39634783.yoshfuji@linux-ipv6.org>
References: <1212491322-9161-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	yoshfuji@linux-ipv6.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58002 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757149AbYFCLe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 07:34:57 -0400
In-Reply-To: <1212491322-9161-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1212491322-9161-1-git-send-email-den@openvz.org> (at Tue,  3 Jun 2008 15:08:42 +0400), "Denis V. Lunev" <den@openvz.org> says:

> ip6_sk_dst_lookup returns held dst entry. It should be released on all paths
> beyond this point. Add missed release when up->pending is set.

Which kernel are you refering?
And, would you please take a look at ipv4 side as well?

--yoshfuji
