From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V4] net: introduce ethernet teaming device
Date: Tue, 25 Oct 2011 09:02:49 +0200
Message-ID: <20111025070248.GB2070@minipsycho>
References: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
 <CAHXqBFLzuxaCW-q5X066zM3E_t9KHO1uTF6WD3Je2u0EifaSSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab1JYHDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Oct 2011 03:03:03 -0400
Content-Disposition: inline
In-Reply-To: <CAHXqBFLzuxaCW-q5X066zM3E_t9KHO1uTF6WD3Je2u0EifaSSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 24, 2011 at 07:22:36PM CEST, mirqus@gmail.com wrote:
>2011/10/24 Jiri Pirko <jpirko@redhat.com>:
>> This patch introduces new network device called team. It supposes to=
 be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>[...]
>> =C2=A0drivers/net/team/team.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 | 1573 +++++++++++++++++++++++++++++
>> =C2=A0drivers/net/team/team_mode_activebackup.c | =C2=A0152 +++
>> =C2=A0drivers/net/team/team_mode_roundrobin.c =C2=A0 | =C2=A0107 ++
>
>I think this mode-modularity is overkill. One mode will compile to at
>most a few hundred bytes of code+data, but will use at least 10 times
>that to get loaded and tracked properly. How often/how many more modes
>you anticipate to be introduced? You could just keep the modular
>design but drop the kernel module separation and maybe have modes
>conditionally compiled (for those from the embedded world squeezing
>every byte).

~3-4 modes are coming in at least. I presume it would be possible to
squeeze "bacic modes" like roundrobin and activebackup directly into
team.c (or into team_basic_modes.c compiled in team.ko). But I would
leave that to future follow up patch.

>
>Best Regards,
>Micha=C5=82 Miros=C5=82aw
