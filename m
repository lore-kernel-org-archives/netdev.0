From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Shared i2c adapter locking
Date: Tue, 17 Nov 2009 13:32:54 +0000
Message-ID: <1258464774.2732.6.camel@achroite.uk.solarflarecom.com>
References: <20091105150715.692b5200@hyperion.delvare>
	 <20091117193313.b750804e.sfr@canb.auug.org.au>
	 <20091117103554.03971b2f@hyperion.delvare>
	 <20091117.035147.80164577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: khali@linux-fr.org, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	mika.kuoppala@nokia.com, linux-i2c@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752693AbZKQNc6@vger.kernel.org>
In-Reply-To: <20091117.035147.80164577.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-17 at 03:51 -0800, David Miller wrote:
> From: Jean Delvare <khali@linux-fr.org>
> Date: Tue, 17 Nov 2009 10:35:54 +0100
>=20
> > If you did and something is still not clear, please let me know. My
> > understanding is that the action token is in David's hands now.
>=20
> So what exactly do I need to do?
>=20
> All I see that needs to happen is to pull from Linus's tree into
> net-2.6
>=20
> But frankly I don't see how that helps resolve anything in linux-next
> since Stephen starts with Linus's tree then pulls in everyone's work.
>=20
> Or is that pull necessary so that some other patch can be applied
> to net-2.6 or similar?

There is now a conflict between this in Linus's tree:

commit afa08974fe80c198b8650f73ed8ab59135ca10d0
Author: Jean Delvare <khali@linux-fr.org>
Date:   Sat Nov 7 13:10:46 2009 +0100

    i2c: Add an interface to lock/unlock an I2C bus segment

and =EF=BB=BFthis in net-next-2.6:

commit c9597d4f89565b6562bd3026adbe6eac6c317f47
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Fri Oct 23 08:29:33 2009 +0000

    sfc: Merge sfe4001.c into falcon_boards.c

You will need to merge Linus's tree into net-next-2.6 and resolve the
conflict by applying Jean's changes to drivers/net/sfc/falcon_boards.c.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
