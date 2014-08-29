From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH ipsec-next v3 2/2] xfrm: configure policy hash table
 thresholds by netlink
Date: Fri, 29 Aug 2014 12:02:00 +0200
Message-ID: <CADdy8HrmoHRzjM15qg8E-0fMu2Ka7VFqweZKYO1WuXj8sNu2cg@mail.gmail.com>
References: <20140821060944.GC6390@secunet.com>
	<1409154495-1343-1-git-send-email-christophe.gouault@6wind.com>
	<1409154495-1343-3-git-send-email-christophe.gouault@6wind.com>
	<20140829095431.GF6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:59238 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaH2KCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 06:02:02 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so2397423ier.6
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 03:02:00 -0700 (PDT)
In-Reply-To: <20140829095431.GF6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-29 11:54 GMT+02:00 Steffen Klassert <steffen.klassert@secunet.com>:
> On Wed, Aug 27, 2014 at 05:48:15PM +0200, Christophe Gouault wrote:
>>
>> +static int xfrm_set_spdinfo(struct sk_buff *skb, struct nlmsghdr *nlh,
>> +                         struct nlattr **attrs)
>> +{
>> +     struct net *net = sock_net(skb->sk);
>> +     u32 *flags = nlmsg_data(nlh);
>> +     u32 sportid = NETLINK_CB(skb).portid;
>> +     u32 seq = nlh->nlmsg_seq;
>
> flags, sportid and seq are unused now. Please remove them.

OK, I'll send an update.

Christophe.
