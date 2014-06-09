From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH net-next] net: force a list_del() in unregister_netdevice_many()
Date: Mon, 9 Jun 2014 09:27:24 +0800
Message-ID: <53950D7C.5060001@cn.fujitsu.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>	 <1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>	 <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_iQpWeq6a+ighGoLXqDp06t+D97adFrtRpM+ACqtf3J4SUNg@mail.gmail.com>	 <1402060661.3645.289.camel@edumazet-glaptop2.roam.corp.google.com> <1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:30403 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753487AbaFIB2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 21:28:05 -0400
In-Reply-To: <1402062243.3645.295.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2014 09:44 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> unregister_netdevice_many() API is error prone and we had too
> many bugs because of dangling LIST_HEAD on stacks.
> 
> See commit f87e6f47933e3e ("net: dont leave active on stack LIST_HEAD")
> 
> In fact, instead of making sure no caller leaves an active list_head,
> just force a list_del() in the callee. No one seems to need to access
> the list after unregister_netdevice_many()
> 

Just like the patch I posted one year ago, interesting :)
http://patchwork.ozlabs.org/patch/223521/
