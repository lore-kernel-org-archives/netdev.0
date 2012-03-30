From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
        <u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 00/17] mark const init data with __initconst instead of
 __initdata
Date: Fri, 30 Mar 2012 11:59:00 +0200
Message-ID: <20120330095859.GT15647@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
        Anatolij Gustschin <agust@denx.de>,
        Andreas Koensgen <ajk@comnets.uni-bremen.de>,
        Andrew Lunn <andrew@lunn.ch>,
        Andrew Victor <linux@maxim.org.za>,
        Arnd Bergmann <arnd@arndb.de>,
        Barry Song <baohua.song@csr.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Bryan Huntsman <bryanh@codeaurora.org>,
        cbe-oss-dev@lists.ozlabs.org,
        Christoph Lameter <cl@linux-foundation.org>,
        Daniel Walker <dwalker@fifo99.com>,
        David Brown <davidb@codeaurora.org>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Woodhouse <dwmw2@infradead.org>,
        davinci-linux-open-source@linux.davincidsp.com,
        Eric Miao <eric.y.miao@gmail.com>,
        Fenghua Yu <fenghua.yu@intel.com>,
        Grant Likely <gran
To: linux-kernel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 29, 2012 at 11:11:31PM +0200, Uwe Kleine-K=F6nig wrote:
> Hello,
>=20
> this series fixes a common error to use __initdata to mark const
> variables. Most of the time this works well enough to go unnoticed
> (though I wonder why the linker doesn't warn about that).
> Just try adding something like
>=20
> 	int something __initdata;
>=20
> to one of the patched files and compile to see the error.
>=20
> While touching these annotations I also corrected the position where =
it
> was wrong to go between the variable name and the =3D.
>=20
> Note this series is not compile tested.
After a question by Shawn Guo I noticed that my command to do the chang=
es
was to lax and changed things that must not be changed (at least not
with further care). Affected are lines like:

	static const char *at91_dt_board_compat[] __initconst =3D {

While at91_dt_board_compat[0] is const, at91_dt_board_compat is not.

I will send a fixed series later today.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
