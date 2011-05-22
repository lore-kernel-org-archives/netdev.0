From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 11:37:59 +0200
Message-ID: <20110522093758.GC2611@jirka.orion>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net>
 <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion>
 <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com>
 <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com>
 <20110522062915.GA2611@jirka.orion>
 <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, ebiederm@xmission.com
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab1EVJiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 05:38:11 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, May 22, 2011 at 10:38:45AM CEST, xiaosuo@gmail.com wrote:
>On Sun, May 22, 2011 at 2:29 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>> Sun, May 22, 2011 at 04:59:49AM CEST, nicolas.2p.debian@gmail.com wrote:
>>
>> <snip>
>>>
>>>And because some setups may still require the skb not to be untagged,
>>>may be we need the ability to re-tag the skb in some situations...
>>>When a protocol handler or rx_handler is explicitly registered on a
>>>net_device which expect to receive tagged skb, we should deliver
>>>tagged skb to it... Arguably, this may sound incredible for the
>>>general case, but may be required for not-so-special cases like
>>>bridge or protocol analyzer.
>>
>> Wait, what setups/code require the skb not to be untagged? If there's
>> such, it should be fixed.
>>
>
>For a transparent bridge with ports: eth0 and eth1, the vlan tags
>need to be preserved.

Yet they are - in skb->vlan_tci. I see no problem here. It's the same as
if the NIC does hw-untagging itself.

Jirka
>
>-- 
>Regards,
>Changli Gao(xiaosuo@gmail.com)
