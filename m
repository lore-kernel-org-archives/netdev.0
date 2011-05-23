From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 10:14:02 +0800
Message-ID: <BANLkTi=BN6Aza7eU=D+WqJgVsVuswT5PDg@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org> <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
 <m1ei3qjzix.fsf_-_@fess.ebiederm.org> <4DD97A44.2020708@candelatech.com>
 <m1wrhigy37.fsf@fess.ebiederm.org> <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
 <BANLkTik6etR8V1qeDnYBKt6BaODBe8kUOw@mail.gmail.com> <m1ei3qdwa6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	=?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:51896 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab1EWCOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 22:14:23 -0400
Received: by bwz15 with SMTP id 15so4336014bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 19:14:22 -0700 (PDT)
In-Reply-To: <m1ei3qdwa6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 9:45 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>> In another side, is there a specification which defines the
>> hw-accel-vlan-rx?
>
> I don't know.
>
> I have just been trying to clean up the mess since some of the
> hw-accel-vlan code broke my use case, by delivering packets with
> priority but no vlan (aka vlan 0 packets) twice to my pf_packet sockets.
>

OK. But if we have decided to simulate the hw-accel-vlan-rx, I think
we'd better adjust the place where we put the emulation code. The very
beginnings of netif_rx() and neif_receive_skb() are better. Then rps
can support vlan packets without any change.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
