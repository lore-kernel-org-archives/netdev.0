From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] act_mirred: don't clone skb when skb isn't shared
Date: Mon, 28 Jun 2010 23:38:41 -0700 (PDT)
Message-ID: <20100628.233841.27800650.davem@davemloft.net>
References: <1277432712-2869-1-git-send-email-xiaosuo@gmail.com>
	<1277469551.5438.0.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37664
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752928Ab0F2Gi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:38:28 -0400
In-Reply-To: <1277469551.5438.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Fri, 25 Jun 2010 08:39:11 -0400

> On Fri, 2010-06-25 at 10:25 +0800, Changli Gao wrote:
>> don't clone skb when skb isn't shared
>> 
>> When the tcf_action is TC_ACT_STOLEN, and the skb isn't shared, we don't need
>> to clone a new skb. As the skb will be freed after this function returns, we
>> can use it freely once we get a reference to it.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied.
