From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 4/3] net/bonding: Adhere to coding style: break line after
 the if condition
Date: Wed, 28 Nov 2007 17:01:23 -0800
Message-ID: <474E0F63.5060702@oracle.com>
References: <871wabkxcd.fsf@szonett.ki.iif.hu>	<20071127194929.757e4ebe.randy.dunlap@oracle.com>	<87bq9ekb8m.fsf@szonett.ki.iif.hu> <474D8B83.9050609@oracle.com> <87wss1c3d8.fsf_-_@szonett.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?utf-8?q?Ferenc_W=C3=A1gner?= <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:24956 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757010AbXK2BC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2007 20:02:29 -0500
In-Reply-To: <87wss1c3d8.fsf_-_@szonett.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=3D?utf-8?q?Ferenc_W=3DC3=3DA1gner?=3D wrote:
> Signed-off-by: Ferenc W=E1gner <wferi@niif.hu>

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> ---
> Randy Dunlap <randy.dunlap@oracle.com> writes:
>=20
>  drivers/net/bonding/bond_sysfs.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/b=
ond_sysfs.c
> index 5c31f5c..9de2c52 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -91,7 +91,8 @@ static ssize_t bonding_show_bonds(struct class *cls=
, char *buf)
>  		}
>  		res +=3D sprintf(buf + res, "%s ", bond->dev->name);
>  	}
> -	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
> +	if (res)
> +		buf[res-1] =3D '\n'; /* eat the leftover space */
>  	up_read(&(bonding_rwsem));
>  	return res;
>  }
> @@ -239,7 +240,8 @@ static ssize_t bonding_show_slaves(struct device =
*d,
>  		res +=3D sprintf(buf + res, "%s ", slave->dev->name);
>  	}
>  	read_unlock(&bond->lock);
> -	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
> +	if (res)
> +		buf[res-1] =3D '\n'; /* eat the leftover space */
>  	return res;
>  }
> =20
> @@ -705,7 +707,8 @@ static ssize_t bonding_show_arp_targets(struct de=
vice *d,
>  			res +=3D sprintf(buf + res, "%u.%u.%u.%u ",
>  			       NIPQUAD(bond->params.arp_targets[i]));
>  	}
> -	if (res) buf[res-1] =3D '\n'; /* eat the leftover space */
> +	if (res)
> +		buf[res-1] =3D '\n'; /* eat the leftover space */
>  	return res;
>  }
> =20


--=20
~Randy
