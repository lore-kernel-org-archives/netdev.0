From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Shared i2c adapter locking
Date: Thu, 05 Nov 2009 13:57:24 +0000
Message-ID: <1257429444.2793.2.camel@achroite.uk.solarflarecom.com>
References: <20091026133757.7cf87e49.sfr@canb.auug.org.au>
	 <20091029154317.651904b9@hyperion.delvare>
	 <1256828976.2827.27.camel@achroite>
	 <20091105141122.56b6b4f8@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mika Kuoppala <mika.kuoppala@nokia.com>,
	Linux I2C <linux-i2c@vger.kernel.org>
To: Jean Delvare <khali@linux-fr.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091105141122.56b6b4f8@hyperion.delvare>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-11-05 at 14:11 +0100, Jean Delvare wrote:
[...]
> What about the following patch?
>=20
> From: Jean Delvare <khali@linux-fr.org>
> Subject: i2c: Add an interface to lock/unlock I2C bus segment
>=20
> Some drivers need to be able to prevent access to an I2C bus segment
> for a specific period of time. Add an interface for them to do so
> without twiddling with i2c-core internals.
>=20
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
Acked-by: =EF=BB=BFBen Hutchings <bhutchings@solarflare.com>

Presumably this is meant for net-next-2.6, and you'll implement
i2c_{lock,unlock}_adapter() using rt_mutex in your i2c tree?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
