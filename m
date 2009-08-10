From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] [NET] ixp2000/enp2611: don't set non-existent
 member get_stats
Date: Mon, 10 Aug 2009 08:00:42 -0700 (PDT)
Message-ID: <20090810.080042.259707687.davem@davemloft.net>
References: <1249677761-19470-5-git-send-email-u.kleine-koenig@pengutronix.de>
	<20090809.214906.143672876.davem@davemloft.net>
	<20090810094027.GA22200@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, linux@arm.linux.org.uk,
	dbaryshkov@gmail.com, kernel@wantstofly.org, netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090810094027.GA22200@pengutronix.de>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon, 10 Aug 2009 11:40:27 +0200

> Yes, I tried that, but stopped when I saw it's declared const.  I don=
't
> know if this is required.  If yes then the only way to fix it is to a=
dd
> a platform callback that is called if non-NULL.

The easiest way to handle this is to have another copy of the ops,
which has the other get_stats member value, and to assign that as
the netdev_ops when the relevant condition holds.

> I don't want to invest time here without a word by the maintainers
> though.

But we can't apply the patch you initially posted, that's for sure
:-)
--
To unsubscribe from this list: send the line "unsubscribe linux-rt-user=
s" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
