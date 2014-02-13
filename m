From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 5/5] ixgbe: fixup warning regarding max_vfs parameter
Date: Thu, 13 Feb 2014 20:01:32 +0000
Message-ID: <1392321692.15615.48.camel@deadeye.wl.decadent.org.uk>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
	 <1392278450-27062-6-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KzHmcNUu+Nng4zpE74SV"
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55748 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750892AbaBMUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:01:50 -0500
In-Reply-To: <1392278450-27062-6-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KzHmcNUu+Nng4zpE74SV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-13 at 00:00 -0800, Aaron Brown wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
>=20
> The max_vfs parameter for ixgbe is deprecated in favor of using the
> sysfs sriov_numvfs field to assign VFs as needed, instead of fixing the
> value at module load time. The current message only indicates that you
> should use this, without adequately explaining how to do so.

I don't think the kernel log is the correct place to put documentation.
A reference alone should be enough.

[...]
> +               e_dev_warn("See 'Documentation/PCI/pci-iov-howto.txt for =
more information.\n");
[...]

This doesn't seem very helpful to non-developers.  You could instead
give the URL:

https://www.kernel.org/doc/Documentation/PCI/pci-iov-howto.txt

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-KzHmcNUu+Nng4zpE74SV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUv0knOe/yOyVhhEJAQrhDxAAu9NS+FgQZlsIQ6xSFdzK6Rn1kdSwKsOG
h9zCBYZRQsDJrmhUpJstGiwtYvYF7Oenx3KZLuRUeuPyGhcQOLUKADeCfnftyScj
/G7IqOUP8t53jkVn2lI8DCb6cHccnIDV+fE93TEZQZ6XOmnvG2uyNrGLW1xclS9j
y+aIsUPOaRSic2DyQMt7t1Li2WuShf160kJBhjr5m9EYJejWhDycsCNgrKPXXTOs
Hnpy6plIhlEl5U/x6PCg8+9oYCR8OciWB12YVFr5PrXV7biktaU6RU4M+u3Uydfa
x1YQeNoIiNhmqea/DAqKUF0SnH8RO6wYmKmgxkDqCcUl7jJzSs573eHCeqWMbrA+
PSE+gGQMQCyjrKyMbSFCsJ717wSKu948i2VZsGZ8xz4WlEyo5+wPUYi1XUzS+T6/
I4LdNsuAYGirZvHRDMeExVKe/T4Cgzlm76ljvyh+uX/8q4goLnZ61oUzA2w1t7Ko
joT43Qa0+c3CDk/rvx1jGpWzuX16VLWMaDgv0EnxNBOSlad17fgd9PC1M+XkCoq9
T3R8FSP4xpz8BWX4AEJ0dAnYYil5U1WtjAOZBgIgG0r7u9jMMuswGqHy9hHfiTwY
TPTMBHLYnBhHriSuzx9CJwzTVZ4305QSdD7PJoKB37txmxNxmupRbYRgqXgVYiBG
w/HmJLAf7kI=
=5bn9
-----END PGP SIGNATURE-----

--=-KzHmcNUu+Nng4zpE74SV--
