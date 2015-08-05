From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 1/5] device property: helper macros for property entry
 creation
Date: Wed, 05 Aug 2015 17:02:18 +0300
Message-ID: <1438783338.29746.172.camel@linux.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1438781947-7952-2-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-tegra@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438781947-7952-2-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:
> Marcos for easier creation of build-in property entries.
>=20
> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> ---
>  include/linux/property.h | 35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
>=20
> diff --git a/include/linux/property.h b/include/linux/property.h
> index 76ebde9..204d899 100644
> --- a/include/linux/property.h
> +++ b/include/linux/property.h
> @@ -152,6 +152,41 @@ struct property_entry {
>  	} value;
>  };
> =20
> +#define PROP_ENTRY_U8(_name_, _val_) { \

PROP_ prefix is too generic.
Maybe DEVPROP_ ? At least for the latter no records in the current
sources.

> +	.name =3D _name_, \
> +	.type =3D DEV_PROP_U8, \
> +	.nval =3D 1, \
> +	.value.u8_data =3D _val_, \
> +}
> +
> +#define PROP_ENTRY_U16(_name_, _val_) { \
> +	.name =3D _name_, \
> +	.type =3D DEV_PROP_U16, \
> +	.nval =3D 1, \
> +	.value.u16_data =3D _val_, \
> +}
> +
> +#define PROP_ENTRY_U32(_name_, _val_) { \
> +	.name =3D _name_, \
> +	.type =3D DEV_PROP_U32, \
> +	.nval =3D 1, \
> +	.value.u32_data =3D _val_, \
> +}
> +
> +#define PROP_ENTRY_U64(_name_, _val_) { \
> +	.name =3D _name_, \
> +	.type =3D DEV_PROP_U64, \
> +	.nval =3D 1, \
> +	.value.u64_data =3D _val_, \
> +}
> +
> +#define PROP_ENTRY_STRING(_name_, _val_) { \

=E2=80=A6_STRING_ARRAY I can notice.

> +	.name =3D _name_, \
> +	.type =3D DEV_PROP_STRING, \
> +	.nval =3D 1, \
> +	.value.str =3D (const char **)_val_, \
> +}
> +
>  /**
>   * struct property_set - Collection of "built-in" device properties.
>   * @fwnode: Handle to be pointed to by the fwnode field of struct=20
> device.

--=20
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
