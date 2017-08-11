From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working with wireless drivers
Date: Fri, 11 Aug 2017 16:14:48 +0300
Message-ID: <87tw1edz5j.fsf@kamboji.qca.qualcomm.com>
References: <87shh0gewn.fsf@kamboji.qca.qualcomm.com>
        <8845e49b-3165-e6df-5935-c86278d220d9@broadcom.com>
        <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Mahesh Bandewar <maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Andy Gospodarek <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Feeney <james-fvV4AYHggTTR7s880joybQ@public.gmane.org>
To: Andreas Born <futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CADps9UA7S2betC-+5sOXjYWmDC8gnk6JJ9aEueEOoYAC3DU8hg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
        (Andreas Born's message of "Thu, 10 Aug 2017 19:52:03 +0200")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andreas Born <futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:

> Earlier today I submitted the patch (bonding: require speed/duplex
> only for 802.3ad, alb and tlb) [2] that only partially reverts what is
> a regression following my aforementioned logic. This seems to me like
> the best solution in the short term since it should satisfy both
> usergroups represented by Mahesh and James and restores consistence
> with the bonding documentation. James already commented approvingly on
> that patch in the bug report. [3]
>
> Regards
> Andreas
>
> [1]
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/bonding.txt

Great, thanks.

I'll take it the patch is meant for net tree (and not net-next) so that
it will be fixed for v4.13? Also it should backported to v4.12 stable
tree. I don't see any mention of that in the patch submission and that's
why I'm asking.

-- 
Kalle Valo
