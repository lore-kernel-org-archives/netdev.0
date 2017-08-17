From: Jay Vosburgh <jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: Regression: Bug 196547 - Since 4.12 - bonding module not working with wireless drivers
Date: Wed, 16 Aug 2017 22:33:41 -0700
Message-ID: <28296.1502948021@famine>
References: <CADps9UCgqeUh41iHxCM+CTJh=Tffn-tiSYL2Q+NBb_8EppqRMA@mail.gmail.com> <2b6fd91a-f7cd-c2bf-6394-060d9b1f5d23@nurealm.net> <1502918561.30484.1.camel@redhat.com> <20170816.143116.1172751167543812070.davem@davemloft.net> <1502935907.30484.4.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, james-fvV4AYHggTTR7s880joybQ@public.gmane.org,
        futur.andy-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, maheshb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1502935907.30484.4.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-ID: <28295.1502948021.1@famine>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
[...]
>You'll probably say "aim for the 75% case" or something like that,
>which is fine, but then you're depending on your 75% case to be (a)
>single AP, (b) never move (eg, only bond wifi + ethernet), (c) little
>radio interference.  I'm not sure I'd buy that.  If I've put words in
>your mouth, forgive me.

	The primary use case that I'm aware of for bonding with wireless
devices is in active-backup mode, paired with an ethernet adapter set as
the bonding "primary" device.  I think this is the case that absolutely
should just work.  I don't think bonding cares (or should care) about
(a) - (c) for this use.

	Your point (b) suggests that there are use cases other than the
above; I'm unfamiliar with any use other than wifi + ethernet, can you
elaborate?

	-J

---
	-Jay Vosburgh, jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
