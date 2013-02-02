From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v9 net-next 02/12] bridge: Validate that vlan is permitted
 on ingress
Date: Fri, 01 Feb 2013 21:13:11 -0500
Message-ID: <510C7637.7080102@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <1359748930-31475-3-git-send-email-vyasevic@redhat.com> <CAHXqBFLTaPbReQh-vgc_kbBbUtEWOFyE2oq85boWoHFD2+Tm9w@mail.gmail.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756721Ab3BBCNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 21:13:15 -0500
In-Reply-To: <CAHXqBFLTaPbReQh-vgc_kbBbUtEWOFyE2oq85boWoHFD2+Tm9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2013 08:04 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2013/2/1 Vlad Yasevich <vyasevic@redhat.com>:
>> When a frame arrives on a port or transmitted by the bridge,
>> if we have VLANs configured, validate that a given VLAN is allowed
>> to enter the bridge.
> [...]
>> +static inline struct net_port_vlans *br_get_vlan_info(
>> +                                               const struct net_bri=
dge *br)
>> +{
>> +       return rcu_dereference(br->vlan_info);
>> +}
>> +
>> +static inline struct net_port_vlans *nbp_get_vlan_info(
>> +                                               const struct net_bri=
dge_port *p)
>> +{
>> +       return rcu_dereference(p->vlan_info);
>> +}
>
> Those should go to patch #1.

They are not needed till here.  I thought it would read/review better i=
f=20
I kept it together.

-vlad
>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
>
