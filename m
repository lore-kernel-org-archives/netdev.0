From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:02:14 +0200
Message-ID: <44A55916.6050003@trash.net>
References: <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2> <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch> <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <44A52435.20909@6wind.com> <44A558CD.4020600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42625 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751806AbWF3RCQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 13:02:16 -0400
To: nicolas.dichtel@6wind.com
In-Reply-To: <44A558CD.4020600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Nicolas Dichtel wrote:
> 
>>Bit 8 of skb->tc_verd is set by IFB, so packet isn't reclassify.
>>This bit avoid the loop.
> 
> 
> It would, if something would actually set it.
> 
> ~/src/kernel/linux-2.6$ grep NCLS -r net/
> net/core/dev.c: if (skb->tc_verd & TC_NCLS) {
> net/core/dev.c:         skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
> net/sched/act_api.c:    if (skb->tc_verd & TC_NCLS) {
> net/sched/act_api.c:            skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
> net/sched/act_api.c:            D2PRINTK("(%p)tcf_action_exec: cleared
> TC_NCLS in %s out %s\n",
> ~/src/kernel/linux-2.6$
> 
> Am I missing something? Jamal, where is this bit supposed to be set?

OK, I'm apparently missing the ability to read :) Please disregard ..
