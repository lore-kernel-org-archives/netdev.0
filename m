From: Jesse Gross <jesse@nicira.com>
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path
 similar to hw-accel
Date: Sun, 22 May 2011 09:11:01 -0700
Message-ID: <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion> <m17h9jp7js.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?Q?Nicolas_de_Peslo=C3=BCan?= <nicolas.2p.debian@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45196 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141Ab1EVQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 12:11:22 -0400
Received: by vws1 with SMTP id 1so3613917vws.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 09:11:21 -0700 (PDT)
In-Reply-To: <m17h9jp7js.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2011 at 11:34 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Jiri Pirko <jpirko@redhat.com> writes:
>
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
>
> tcpdump on the non-vlan interface for one.

There are some drivers still using the old vlan model that will drop
tags or packets when no vlan group is configured but that's a driver
problem, not one with networking core or tcpdump.
