From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/7] udp: Generic functions to set checksum
Date: Wed, 04 Jun 2014 15:16:26 -0700 (PDT)
Message-ID: <20140604.151626.2115057173229567050.davem@davemloft.net>
References: <alpine.DEB.2.02.1406012047250.9052@tomh.mtv.corp.google.com>
	<CAHA+R7NYRg8Mt3_=G3728pN2cJSTth49EVfDADCzZCoZ10npJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaFDWQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:16:27 -0400
In-Reply-To: <CAHA+R7NYRg8Mt3_=G3728pN2cJSTth49EVfDADCzZCoZ10npJQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 2 Jun 2014 16:43:04 -0700

> On Sun, Jun 1, 2014 at 9:00 PM, Tom Herbert <therbert@google.com> wrote:
>> +
>> +
>> +/* Function to set UDP checksum for an IPv6 UDP packet. This is intended
>> + * for the simple case like when setting the checksum for a UDP tunnel.
>> + */
>> +static inline void udp6_set_csum(struct sock *sk, struct sk_buff *skb,
>> +                                const struct in6_addr *saddr,
>> +                                const struct in6_addr *daddr, int len)
>> +{
> 
> I think this function might be too big to be inlined.
> 
> Ditto for udp_set_csum().

Agreed, Tom please put these into a *.c file and export them.
