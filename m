From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] netconsole support for b44
Date: Wed, 13 Oct 2004 07:48:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416C5122.9040001@kolivas.org>
References: <416BC26B.6090603@kolivas.org> <20041012180949.GW5414@waste.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigBF3A108614D7BD67726F038C"
Cc: netdev@oss.sgi.com,
        linux kernel mailing list <linux-kernel@vger.kernel.org>,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20041012180949.GW5414@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigBF3A108614D7BD67726F038C
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Matt Mackall wrote:
> On Tue, Oct 12, 2004 at 09:39:23PM +1000, Con Kolivas wrote:
> 
>>This patch adds poll support to the b44 driver to allow netconsole 
>>support. Style lifted straight from 8139too.c
>>
>>here is the dmesg output with it in place:
>>
>>netconsole: device eth0 not up yet, forcing it
>>netconsole: carrier detect appears flaky, waiting 10 seconds
>>b44: eth0: Link is down.
>>b44: eth0: Link is up at 100 Mbps, full duplex.
>>b44: eth0: Flow control is on for TX and on for RX.
>>netconsole: network logging started
>>
>>output confirmed by netcat on other system.
>>
>>Signed-off-by: Con Kolivas <kernel@kolivas.org>
> 
> 
> +       disable_irq(dev->irq);
> +       b44_interrupt (dev->irq, dev, NULL);
> +       enable_irq(dev->irq);
> 
> Aside from this bizarre whitespace convention and neglecting to cc:
> me, looks good.
> 

sorry,sorry,thanks.

Can you explain where I went wrong in the whitespace so I don't make the 
same mistake again? It looked pretty standard to me.

Should I nudge akpm with this or will it go via another route?

Cheers,
Con

--------------enigBF3A108614D7BD67726F038C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBbFEkZUg7+tp6mRURAlWCAJ4oaRD1BZfn4t1aFQdzT5GHZA14mwCfZ08d
c/pMvPFNLqseH5ekm/xyvZY=
=wXV5
-----END PGP SIGNATURE-----

--------------enigBF3A108614D7BD67726F038C--
