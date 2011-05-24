From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Tue, 24 May 2011 09:44:42 +0200
Message-ID: <BANLkTikxNNpaXSkNaf6b2GHgaEZQ5HiO2g@mail.gmail.com>
References: <4DDAB72B.9050101@gmail.com> <4DDAC26C.2070601@candelatech.com>
 <20110523140048.777fb378@nehalam> <20110523.172047.1438754754048434316.davem@davemloft.net>
 <m1y61x2htp.fsf@fess.ebiederm.org> <4DDADE52.8000008@candelatech.com>
 <m1boyt10n4.fsf@fess.ebiederm.org> <4DDB3226.8010404@candelatech.com> <4DDB5A3F.8050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, jpirko@redhat.com,
	xiaosuo@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	fubar@us.ibm.com, eric.dumazet@gmail.com, andy@greyhouse.net,
	jesse@nicira.com
To: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:38949 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089Ab1EXHpD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:45:03 -0400
Received: by qyk7 with SMTP id 7so1295757qyk.19
        for <netdev@vger.kernel.org>; Tue, 24 May 2011 00:45:03 -0700 (PDT)
In-Reply-To: <4DDB5A3F.8050007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/24 Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>:
>> If it turns out the NIC is not stripping VLAN tags for whatever reas=
on,
>> we might be able to optimize things so that it never does the HW emu=
lation
>> so that it never has to un-do it later.
> It might be very tricky to avoid any do-undo-redo situation. I will l=
atter
> try and describe all the possible situations: with/without hw-accel,
> with/without a protocol handler registered on the parent interface,
> with/without a child interface build on top of a particular parent in=
terface
> and with the corresponding VLAN ID...

Hardware tag stripping could be disabled whenever AF_PACKET listener
is present on the base interface. It should be easy now with the new
features handling.

BTW, what's the performance gain from hw tag stripping? Besides saving
12-byte memmove() in one cacheline?

Best Regards,
Micha=B3 Miros=B3aw
