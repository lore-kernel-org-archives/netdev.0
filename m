From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Mon, 23 May 2011 08:38:36 +0800
Message-ID: <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
 <20110412.141645.112604563.davem@davemloft.net> <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion> <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com> <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org> <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
 <m1ei3qjzix.fsf_-_@fess.ebiederm.org> <4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49842 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755788Ab1EWAi7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:38:59 -0400
Received: by bwz15 with SMTP id 15so4298244bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:38:57 -0700 (PDT)
In-Reply-To: <m1wrhigy37.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 6:38 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
>> Many years ago we supported the REORDER, but we suggested disabling
>> it for most users because it was a performance drag. =A0Funny that n=
ow
>> it seems to be the opposite!
>
> Yes it is funny. =A0I looked in history a while back and what I saw w=
as
> that REORDER was always enabled by default and it took some serious
> effort to figure out how to get vconfig to disable REORDER. ip doesn'=
t
> admit that REORDER can be disabled at all.
>

Really?

Quoted from the manual page of vconfig
       set_flag [vlan-device] 0 | 1
              When  1,  ethernet  header  reorders  are turned on. Dump=
ing the
              device will appear as a common ethernet  device  without =
 vlans.
              When  0(default)  however,  ethernet  headers are not reo=
rdered,
              which results in vlan tagged packets when  dumping  the  =
device.
              Usually the default gives no problems, but some packet fi=
ltering
              programs might have problems with it.

reordered is disabled by default. I also concern the performance.
Untag and then tag are expensive for the NICs which don't support
hw-accel-vlan-rx/tx.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
