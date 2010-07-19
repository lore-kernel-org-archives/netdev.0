From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC 0/2] netfilter: xtables: CONDITION target implementation
Date: Mon, 19 Jul 2010 22:27:25 +0800
Message-ID: <AANLkTilRtCiuAwox2sTsEu73fE89OLEUtIbVQ_njtkqz@mail.gmail.com>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, jengelh@medozas.de, sameo@linux.intel.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 19, 2010 at 10:15 PM, Luciano Coelho
<luciano.coelho@nokia.com> wrote:
> From: Luciano Coelho <coelho@testbed.(none)>
>
> Hi all,
>
> As discussed earlier, I've been looking for a way to enable and disab=
le the
> condition match automatically, in the netfilter tables themselves (ie=
=2E without
> the need to use procfs).
>
> This is my initial implementation. =A0Please let me know how it looks=
=2E =A0The first
> patch is based on the xt_condition patch that Jan sent to the list (b=
ut which
> has not been finalized for inclusion yet). =A0Once the condition matc=
h gets
> applied, I'll forward port my patch and submit it again.
>
> Cheers,
> Luca.
>
> Luciano Coelho (2):
> =A0netfilter: xt_condition: export list management code
> =A0netfilter: xtables: implement CONDITION target
>
> =A0include/linux/netfilter/Kbuild =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0include/linux/netfilter/xt_CONDITION.h | =A0 39 +++++++++++
> =A0include/linux/netfilter/xt_condition.h | =A0 17 +++++-
> =A0net/netfilter/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 12 =
++++
> =A0net/netfilter/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 =
+
> =A0net/netfilter/xt_CONDITION.c =A0 =A0 =A0 =A0 =A0 | =A0112 ++++++++=
++++++++++++++++++++++++
> =A0net/netfilter/xt_condition.c =A0 =A0 =A0 =A0 =A0 | =A0 82 ++++++++=
++++++----------

Why not combine xt_CONDITION.c and xt_condition.c into xt_condition.c,
like xt_mark.c?


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
