From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch net-next-2.6 v2] net: vlan: make non-hw-accel rx path similar to hw-accel
Date: Sun, 22 May 2011 03:26:10 -0700
Message-ID: <m1wrhjni9p.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<BANLkTinEnHLx1CVh8p0ejLkcaqoLHw2nOA@mail.gmail.com>
	<20110522093758.GC2611@jirka.orion>
	<BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, Jesse Gross <jesse@nicira.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:51648 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1EVK0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 06:26:18 -0400
In-Reply-To: <BANLkTin6u7VptTm3se_bLdEeTOz2OVc_Rw@mail.gmail.com> (Changli
	Gao's message of "Sun, 22 May 2011 18:17:52 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:

> On Sun, May 22, 2011 at 5:37 PM, Jiri Pirko <jpirko@redhat.com> wrote:
>>>
>>>For a transparent bridge with ports: eth0 and eth1, the vlan tags
>>>need to be preserved.
>>
>> Yet they are - in skb->vlan_tci. I see no problem here. It's the same as
>> if the NIC does hw-untagging itself.
>>
>
> Although they are in skb->vlan_tci, but the xmit nic, which doesn't
> support hw-accel-vlan-tx, doesn't use them to tag the outgoing
> packets. Correct me if I am wrong.

There is software emulation in dev_hard_start_xmit for the nics
that don't support the feature.  So we will properly add tags.

Eric
