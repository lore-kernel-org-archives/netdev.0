From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check v2
Date: Sun, 05 Jun 2011 14:14:46 -0700 (PDT)
Message-ID: <20110605.141446.1838641439880246155.davem@davemloft.net>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
	<BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
	<BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pratnakarlx@gmail.com, ebiederm@xmission.com,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab1FEVQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 17:16:06 -0400
In-Reply-To: <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 3 Jun 2011 11:59:26 +0800

> On Fri, Jun 3, 2011 at 11:34 AM, padmanabh ratnakar
> <pratnakarlx@gmail.com> wrote:
>> Doesnt __vlan_put_tag()/vlan_insert_tag() depend on skb->data pointing
>> to ethernet header.
>> Is'nt the skb->data pointing past ethernet header in netif_receive_skb().
>> Am I missing anything?
> 
> Yes, you are right. skb->data should be adjusted before feeding to
> vlan_insert_tag(), or we make vlan_insert_tag() rely on
> skb->mac_header instead.

I told you guys this is not simple stuff :-)

Even here we have 3 or 4 people who study this code all the time, and
are still having trouble sorting out all of these details.

