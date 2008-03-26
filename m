From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-2.6.26 0/5] [NET] NETNS: several optimization without
 CONFIG_NET_NS.
Date: Tue, 25 Mar 2008 20:03:58 -0700 (PDT)
Message-ID: <20080325.200358.142617606.davem@davemloft.net>
References: <20080326.083948.93645750.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, dlezcano@fr.ibm.com, brian.haley@hp.com,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59515
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751311AbYCZDEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 23:04:02 -0400
In-Reply-To: <20080326.083948.93645750.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 26 Mar 2008 08:39:48 +0900 (JST)

> Okay, here's the respin.  Changes:
> 	Add twsk_net(), twsk_net_set().
> 	Fix missing seq_file_net() conversion in net/ipv4/route.c.
> 	Add net_eq().
> 	Add neigh_parms_net() and pneigh_net().
> 
> Full diffs will follow.
> 
> Changes are also available (on top of net-2.6.26 tree) at
>         git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-netns-20080326

Looks great, pulled and pushed back out to net-2.6.26!
