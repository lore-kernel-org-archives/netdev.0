From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Split driver into .c and .h files.
Date: Mon, 2 Jan 2012 09:44:39 +0100
Message-ID: <CACPM=kWr7X4ACV1r40HL_kQt5iJjh8Nek1GWqqxNJsKaE2zL-A@mail.gmail.com>
References: <1325452525-23476-1-git-send-email-gurligebis@gentoo.org>
	<20120101224909.GA18144@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120101224909.GA18144@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/1 Francois Romieu <romieu@fr.zoreil.com>:
> Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
>> Split the driver into via-rhine.c and via-rhine.h like it should be.
>> There is also a bit of cleanup of checkpatch warnings, other than th=
at,
>> there is no changes to how the code works, it is plain refactoring.
>
> Please don't do that. The .h won't be used elsewhere. It's useless
> (and register definitions stay barely readable).

Hmm, I see your point, was just trying to make the two via drivers more=
 alike :)

> Roger, any comment regarding patches #1 .. #3 ?
>
> rhine_task_{enable / disable} should be balanced in open / close and
> suspend / resume, ok.
>
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
