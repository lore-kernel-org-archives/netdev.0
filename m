From: Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties withrfkill_gpio
Date: Mon, 25 Jan 2016 21:59:04 +0100
Message-ID: <1626364.s6q6eBGYVQ@ax5200p>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <1453712629-143317-4-git-send-email-heikki.krogerus@linux.intel.com> <20160125121840.GA20452@ulmo.nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1990714.Ebrfbf8RNK"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
To: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160125121840.GA20452-AwZRO8vwLAwmlAP/+Wk3EA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart1990714.Ebrfbf8RNK
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Am Montag 25 Januar 2016, 13:18:40 schrieb Thierry Reding:
> On Mon, Jan 25, 2016 at 12:03:48PM +0300, Heikki Krogerus wrote:
> > Pass the rfkill name and type to the device with properties
> > instead of driver specific platform data.
> > 
> > Signed-off-by: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > CC: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
> > ---
> > 
> >  arch/arm/mach-tegra/board-paz00.c | 17 ++++++++++-------
> >  1 file changed, 10 insertions(+), 7 deletions(-)
> 
> Looks fine to me. We might want to wait for Marc (Cc'ed) to give this a
> spin, since I don't have the hardware. For reference, the series can be
> found here:
> 
> 	http://patchwork.ozlabs.org/patch/572640/
> 	http://patchwork.ozlabs.org/patch/572644/
> 	http://patchwork.ozlabs.org/patch/572643/
> 	http://patchwork.ozlabs.org/patch/572642/
> 
> Johannes, I assume that you'll want to take this through your tree
> because of the dependency? In that case:
> 
> Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

seems to work fine. I wish we could instantiate this from device-tree so we 
can finially get rid of this file.

Tested-by: Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>

--nextPart1990714.Ebrfbf8RNK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQEcBAABAgAGBQJWpoyYAAoJEKyeR39HFBtojysH+gPoKfxQC7HZRoPxlW3cvw3w
yQnlrnL8ifHJeFYBiZWSMDZ8COOTb0VkJAfZ/BNTm2+yBPzxPXMNCvrM9B9EHZF/
ikY/8YZ6uMXZqEMguEDxagwGSmr7we8rwAu0NaG+92eS1wYs6sLdBgi6vWxYV9Yy
99/6IdQuCS8ICFWatUlB2FETABxLWtW0o5qW7CoNbCcgRNMqn+csXnBV1kteQK+s
NpKIomwmPqbWXFxYw0sDluVyu6Ljb5NqVh4Z7ybGN+Bjsjerx2+PGUZxIqNNAdNj
dFtB8vAebqxsSdcwPRqhZrh1gCj8JTt9GC8lnAaMU7u6Umw9szAauwq8HmhJBWI=
=9kVs
-----END PGP SIGNATURE-----

--nextPart1990714.Ebrfbf8RNK--
