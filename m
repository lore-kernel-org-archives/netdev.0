From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [Patch][IPv6] Fix wrong routing mechanism for Link Local IPv6
 packets
Date: Wed, 31 Jan 2007 14:09:14 +0900 (JST)
Message-ID: <20070131.140914.105443849.yoshfuji@linux-ipv6.org>
References: <001101c744ec$5ee31720$ccb1220a@ZhaoleiSOTEC>
	<1172119906.2658.4.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47576 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbXAaFIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 00:08:00 -0500
In-Reply-To: <1172119906.2658.4.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1172119906.2658.4.camel@LINE> (at Wed, 21 Feb 2007 23:51:45 -0500), weidong <weid@np.css.fujitsu.com> says:

> 	Thanks for your patch. I think maybe we checking oif first is better,
> and WARN_ON in function rt6_score_route().

Please remove WARN_ON.  Otherwise, I'm fine with it.

--yoshfuji
