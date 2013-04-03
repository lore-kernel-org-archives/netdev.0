From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v5 1/6] drivers: phy: add generic PHY framework
Date: Wed, 3 Apr 2013 16:42:18 +0300
Message-ID: <20130403134102.GC14680@arwen.pp.htv.fi>
References: <1364993634-6378-1-git-send-email-kishon@ti.com>
 <1364993634-6378-2-git-send-email-kishon@ti.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2926794252065107156=="
Cc: broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
 linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org,
 cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org, eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org, swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, sylvester.nawrocki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, santosh.shilimkar-l0cyMroinI0@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1364993634-6378-2-git-send-email-kishon-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

--===============2926794252065107156==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dFWYt1i2NyOo1oI9"
Content-Disposition: inline

--dFWYt1i2NyOo1oI9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 03, 2013 at 06:23:49PM +0530, Kishon Vijay Abraham I wrote:
> The PHY framework provides a set of APIs for the PHY drivers to
> create/destroy a PHY and APIs for the PHY users to obtain a reference to =
the
> PHY with or without using phandle. To obtain a reference to the PHY witho=
ut
> using phandle, the platform specfic intialization code (say from board fi=
le)
> should have already called phy_bind with the binding information. The bin=
ding
> information consists of phy's device name, phy user device name and an in=
dex.
> The index is used when the same phy user binds to mulitple phys.
>=20
> PHY drivers should create the PHY by passing phy_descriptor that has
> describes the PHY (label, type etc..) and ops like init, exit, suspend, r=
esume,
> power_on, power_off.
>=20
> The documentation for the generic PHY framework is added in
> Documentation/phy.txt and the documentation for the sysfs entry is added
> in Documentation/ABI/testing/sysfs-class-phy and the documentation for
> dt binding is can be found at
> Documentation/devicetree/bindings/phy/phy-bindings.txt
>=20
> Signed-off-by: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> ---
>  Documentation/ABI/testing/sysfs-class-phy          |   15 +
>  .../devicetree/bindings/phy/phy-bindings.txt       |   67 +++
>  Documentation/phy.txt                              |  113 ++++
>  MAINTAINERS                                        |    7 +
>  drivers/Kconfig                                    |    2 +
>  drivers/Makefile                                   |    2 +
>  drivers/phy/Kconfig                                |   13 +
>  drivers/phy/Makefile                               |    5 +
>  drivers/phy/phy-core.c                             |  616 ++++++++++++++=
++++++
>  include/linux/phy/phy.h                            |  228 ++++++++
>  10 files changed, 1068 insertions(+)
>  create mode 100644 Documentation/ABI/testing/sysfs-class-phy
>  create mode 100644 Documentation/devicetree/bindings/phy/phy-bindings.txt
>  create mode 100644 Documentation/phy.txt
>  create mode 100644 drivers/phy/Kconfig
>  create mode 100644 drivers/phy/Makefile
>  create mode 100644 drivers/phy/phy-core.c
>  create mode 100644 include/linux/phy/phy.h
>=20
> diff --git a/Documentation/ABI/testing/sysfs-class-phy b/Documentation/AB=
I/testing/sysfs-class-phy
> new file mode 100644
> index 0000000..b735467
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-class-phy
> @@ -0,0 +1,15 @@
> +What:		/sys/class/phy/<phy>/label
> +Date:		Apr 2013
> +KernelVersion:	3.10
> +Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> +Description:
> +		This is a read-only file for getting the label of the phy.
> +
> +What:		/sys/class/phy/<phy>/phy_bind
> +Date:		Apr 2013
> +KernelVersion:	3.10
> +Contact:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> +Description:
> +		This is a read-only file for reading the phy binding
> +		information. It contains the device name of the controller,
> +		the index and the device name of the PHY in that order.
> diff --git a/Documentation/devicetree/bindings/phy/phy-bindings.txt b/Doc=
umentation/devicetree/bindings/phy/phy-bindings.txt
> new file mode 100644
> index 0000000..e7b246a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/phy/phy-bindings.txt
> @@ -0,0 +1,67 @@
> +This document explains only the dt data binding. For general information=
 about
> +PHY subsystem refer Documentation/phy.txt
> +
> +PHY device node
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Required Properties:
> +#phy-cells:	Number of cells in a PHY specifier;  The meaning of all those
> +		cells is defined by the binding for the phy node. The PHY
> +		provider can use the values in cells to find the appropriate
> +		PHY.
> +
> +For example:
> +
> +phys: phy {
> +    compatible =3D "xxx";
> +    reg =3D <...>;
> +    .
> +    .
> +    #phy-cells =3D <1>;
> +    .
> +    .
> +};
> +
> +That node describes an IP block that implements 2 different PHYs. In ord=
er to
> +differentiate between these 2 PHYs, an additonal specifier should be giv=
en
> +while trying to get a reference to it.
> +
> +PHY user node
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> +
> +Required Properties:
> +phys : the phandle for the PHY device (used by the PHY subsystem)
> +
> +Optional properties:
> +phy-names : the names of the PHY corresponding to the PHYs present in the
> +	    *phys* phandle
> +
> +Example 1:
> +usb1: usb_otg_ss@xxx {
> +    compatible =3D "xxx";
> +    reg =3D <xxx>;
> +    .
> +    .
> +    phys =3D <&usb2_phy>, <&usb3_phy>;
> +    phy-names =3D "usb2phy", "usb3phy";
> +    .
> +    .
> +};
> +
> +This node represents a controller that uses two PHYs one for usb2 and on=
e for
> +usb3.
> +
> +Example 2:
> +usb2: usb_otg_ss@xxx {
> +    compatible =3D "xxx";
> +    reg =3D <xxx>;
> +    .
> +    .
> +    phys =3D <&phys 1>;
> +    .
> +    .
> +};
> +
> +This node represents a controller that uses one of the PHYs which is def=
ined
> +previously. Note that the phy handle has an additional specifier "1" to
> +differentiate between the two PHYs.
> diff --git a/Documentation/phy.txt b/Documentation/phy.txt
> new file mode 100644
> index 0000000..7785ec0
> --- /dev/null
> +++ b/Documentation/phy.txt
> @@ -0,0 +1,113 @@
> +			    PHY SUBSYSTEM
> +		  Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> +
> +This document explains the Generic PHY Framework along with the APIs pro=
vided,
> +and how-to-use.
> +
> +1. Introduction
> +
> +*PHY* is the abbreviation for physical layer. It is used to connect a de=
vice
> +to the physical medium e.g., the USB controller has a PHY to provide fun=
ctions
> +such as serialization, de-serialization, encoding, decoding and is respo=
nsible
> +for obtaining the required data transmission rate. Note that some USB
> +controller has PHY functionality embedded into it and others use an exte=
rnal
> +PHY. Other peripherals that uses a PHY include Wireless LAN, Ethernet,
> +SATA etc.
> +
> +The intention of creating this framework is to bring the phy drivers spr=
ead
> +all over the Linux kernel to drivers/phy to increase code re-use and to
> +increase code maintainability.
> +
> +This framework will be of use only to devices that uses external PHY (PHY
> +functionality is not embedded within the controller).
> +
> +2. Creating the PHY
> +
> +The PHY driver should create the PHY in order for other peripheral contr=
ollers
> +to make use of it. The PHY framework provides 2 APIs to create the PHY.
> +
> +struct phy *phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv);
> +struct phy *devm_phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv);
> +
> +The PHY drivers can use one of the above 2 APIs to create the PHY by pas=
sing
> +the device pointer, label, device node, type, phy ops and a driver data.
> +phy_ops is a set of function pointers for performing PHY operations such=
 as
> +init, exit, suspend, resume, power_on and power_off.
> +
> +3. Binding the PHY to the controller
> +
> +The framework provides an API for binding the controller to the PHY in t=
he
> +case of non dt boot.
> +
> +struct phy_bind *phy_bind(const char *dev_name, int index,
> +				const char *phy_dev_name);
> +
> +The API fills the phy_bind structure with the dev_name (device name of t=
he
> +controller), index and phy_dev_name (device name of the PHY). This will
> +be used when the controller requests this phy. This API should be used by
> +platform specific initialization code (board file).
> +
> +In the case of dt boot, the binding information should be added in the dt
> +data of the controller.
> +
> +4. Getting a reference to the PHY
> +
> +Before the controller can make use of the PHY, it has to get a reference=
 to
> +it. This framework provides 6 APIs to get a reference to the PHY.
> +
> +struct phy *phy_get(struct device *dev, int index);
> +struct phy *devm_phy_get(struct device *dev, int index);
> +struct phy *of_phy_get(struct device *dev, const char *phandle, int inde=
x);
> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle, int=
 index);
> +struct phy *of_phy_get_byname(struct device *dev, const char *string);
> +struct phy *devm_of_phy_get_byname(struct device *dev, const char *strin=
g);
> +
> +phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This=
 API
> +uses the binding information added using the phy_bind API to find and re=
turn
> +the appropriate PHY. The only difference between the two APIs is that
> +devm_phy_get associates the device with the PHY using devres on successf=
ul PHY
> +get. On driver detach, release function is invoked on the the devres dat=
a and
> +devres data is freed.
> +
> +of_phy_get and devm_of_phy_get can be used to get the PHY in dt boot. Th=
ese
> +APIs take the phandle and index to get a reference to the PHY. The only
> +difference between the two APIs is that devm_of_phy_get associates the d=
evice
> +with the PHY using devres on successful phy get. On driver detach, relea=
se
> +function is invoked on the devres data and it is freed.
> +
> +of_phy_get_byname and devm_of_phy_get_byname can also be used to get the=
 PHY
> +in dt boot. It is same as the above API except that the user has to pass=
 the
> +phy name as filled in "phy-names" phandle in dt data and the framework w=
ill
> +find the index and get the PHY.
> +
> +5. Releasing a reference to the PHY
> +
> +When the controller no longer needs the PHY, it has to release the refer=
ence
> +to the PHY it has obtained using the APIs mentioned in the above section=
=2E The
> +PHY framework provides 2 APIS to release a reference to the PHY.
> +
> +void phy_put(struct phy *phy);
> +void devm_phy_put(struct device *dev, struct phy *phy);
> +
> +Both these APIs are used to release a reference to the PHY and devm_phy_=
put
> +destroys the devres associated with this PHY.
> +
> +6. Destroying the PHY
> +
> +When the driver that created the PHY is unloaded, it should destroy the =
PHY it
> +created using one of the following 2 APIs.
> +
> +void phy_destroy(struct phy *phy);
> +void devm_phy_destroy(struct device *dev, struct phy *phy);
> +
> +Both these APIs destroys the PHY and devm_phy_destroy destroys the devres
> +associated with this PHY.
> +
> +7. DeviceTree Binding
> +
> +The documentation for PHY dt binding can be found @
> +Documentation/devicetree/bindings/phy/phy-bindings.txt
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 72b0843..f2674e7 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3474,6 +3474,13 @@ S:	Maintained
>  F:	include/asm-generic
>  F:	include/uapi/asm-generic
> =20
> +GENERIC PHY FRAMEWORK
> +M:	Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> +L:	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> +S:	Supported
> +F:	drivers/phy/
> +F:	include/linux/phy/
> +
>  GENERIC UIO DRIVER FOR PCI DEVICES
>  M:	"Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>  L:	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> diff --git a/drivers/Kconfig b/drivers/Kconfig
> index 202fa6d..ad2c374a 100644
> --- a/drivers/Kconfig
> +++ b/drivers/Kconfig
> @@ -162,4 +162,6 @@ source "drivers/irqchip/Kconfig"
> =20
>  source "drivers/ipack/Kconfig"
> =20
> +source "drivers/phy/Kconfig"
> +
>  endmenu
> diff --git a/drivers/Makefile b/drivers/Makefile
> index dce39a9..9da8321 100644
> --- a/drivers/Makefile
> +++ b/drivers/Makefile
> @@ -45,6 +45,8 @@ obj-y				+=3D char/
>  # gpu/ comes after char for AGP vs DRM startup
>  obj-y				+=3D gpu/
> =20
> +obj-y				+=3D phy/
> +
>  obj-$(CONFIG_CONNECTOR)		+=3D connector/
> =20
>  # i810fb and intelfb depend on char/agp/
> diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
> new file mode 100644
> index 0000000..5f85909
> --- /dev/null
> +++ b/drivers/phy/Kconfig
> @@ -0,0 +1,13 @@
> +#
> +# PHY
> +#
> +
> +menuconfig GENERIC_PHY
> +	tristate "PHY Subsystem"
> +	help
> +	  Generic PHY support.
> +
> +	  This framework is designed to provide a generic interface for PHY
> +	  devices present in the kernel. This layer will have the generic
> +	  API by which phy drivers can create PHY using the phy framework and
> +	  phy users can obtain reference to the PHY.
> diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
> new file mode 100644
> index 0000000..9e9560f
> --- /dev/null
> +++ b/drivers/phy/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the phy drivers.
> +#
> +
> +obj-$(CONFIG_GENERIC_PHY)	+=3D phy-core.o
> diff --git a/drivers/phy/phy-core.c b/drivers/phy/phy-core.c
> new file mode 100644
> index 0000000..1d753f2
> --- /dev/null
> +++ b/drivers/phy/phy-core.c
> @@ -0,0 +1,616 @@
> +/*
> + * phy-core.c  --  Generic Phy framework.
> + *
> + * Copyright (C) 2013 Texas Instruments
> + *
> + * Author: Kishon Vijay Abraham I <kishon-l0cyMroinI0@public.gmane.org>
> + *
> + * This program is free software; you can redistribute  it and/or modify=
 it
> + * under  the terms of  the GNU General  Public License as published by =
the
> + * Free Software Foundation;  either version 2 of the  License, or (at y=
our
> + * option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/export.h>
> +#include <linux/module.h>
> +#include <linux/err.h>
> +#include <linux/device.h>
> +#include <linux/slab.h>
> +#include <linux/of.h>
> +#include <linux/phy/phy.h>
> +
> +static struct class *phy_class;
> +static DEFINE_MUTEX(phy_bind_mutex);
> +static LIST_HEAD(phy_bind_list);
> +static int phy_core_init(void);
> +
> +static void devm_phy_release(struct device *dev, void *res)
> +{
> +	struct phy *phy =3D *(struct phy **)res;
> +
> +	phy_put(phy);
> +}
> +
> +static void devm_phy_consume(struct device *dev, void *res)
> +{
> +	struct phy *phy =3D *(struct phy **)res;
> +
> +	phy_destroy(phy);
> +}
> +
> +static int devm_phy_match(struct device *dev, void *res, void *match_dat=
a)
> +{
> +	return res =3D=3D match_data;
> +}
> +
> +static struct phy *phy_lookup(struct device *dev, int index)
> +{
> +	struct phy_bind *phy_bind =3D NULL;
> +
> +	list_for_each_entry(phy_bind, &phy_bind_list, list) {
> +		if (!(strcmp(phy_bind->dev_name, dev_name(dev)) &&
> +				phy_bind->index =3D=3D index)) {
> +			if (phy_bind->phy)
> +				return phy_bind->phy;
> +			else
> +				return ERR_PTR(-EPROBE_DEFER);
> +		}
> +	}
> +
> +	return ERR_PTR(-ENODEV);
> +}
> +
> +static struct phy *of_phy_lookup(struct device_node *node)
> +{
> +	struct phy *phy;
> +	struct device *dev;
> +	struct class_dev_iter iter;
> +
> +	class_dev_iter_init(&iter, phy_class, NULL, NULL);
> +	while ((dev =3D class_dev_iter_next(&iter))) {
> +		phy =3D container_of(dev, struct phy, dev);

it would look a bit better if you provided a to_phy() macro. Specially
since this container_of() repeats multiple times in this file.

> +/**
> + * phy_put() - release the PHY
> + * @phy: the phy returned by phy_get()
> + *
> + * Releases a refcount the caller received from phy_get().
> + */
> +void phy_put(struct phy *phy)
> +{

I would rather:

if (WARN(IS_ERR(phy), "invalid parameter\n"))
	return;

module_put(phy->ops->owner);
put_device(&phy->dev);

that way we can catch users passing bogus pointers here. When PHY layer
is disabled, you want to make this is no-op with a static inline in a
header anyway.

> +struct phy *of_phy_xlate(struct phy *phy, struct of_phandle_args *args)
> +{
> +	return phy;
> +}
> +EXPORT_SYMBOL_GPL(of_phy_xlate);

so you get a PHY and just return it ? What gives ?? (maybe I skipped
some of the discussion...)

> +struct phy *of_phy_get(struct device *dev, int index)
> +{
> +	int ret;
> +	struct phy *phy =3D NULL;
> +	struct phy_bind *phy_map =3D NULL;
> +	struct of_phandle_args args;
> +	struct device_node *node;
> +
> +	if (!dev->of_node) {
> +		dev_dbg(dev, "device does not have a device node entry\n");
> +		return ERR_PTR(-EINVAL);
> +	}
> +
> +	ret =3D of_parse_phandle_with_args(dev->of_node, "phys", "#phy-cells",
> +		index, &args);
> +	if (ret) {
> +		dev_dbg(dev, "failed to get phy in %s node\n",
> +			dev->of_node->full_name);
> +		return ERR_PTR(-ENODEV);
> +	}
> +
> +	phy =3D of_phy_lookup(args.np);
> +	if (IS_ERR(phy) || !try_module_get(phy->ops->owner)) {
> +		phy =3D ERR_PTR(-EPROBE_DEFER);
> +		goto err0;
> +	}
> +
> +	phy =3D phy->ops->of_xlate(phy, &args);

alright, so of_xlate() is optional, am I right ? How about not
implementing the above and have a check for of_xlate() being a valid
pointer here ?

> +struct phy *phy_create(struct device *dev, const char *label,
> +	struct device_node *of_node, int type, struct phy_ops *ops,
> +	void *priv)
> +{
> +	int ret;
> +	struct phy *phy;
> +	struct phy_bind *phy_bind;
> +	const char *devname =3D NULL;
> +
> +	if (!dev) {
> +		dev_err(dev, "no device provided for PHY\n");

I'd call this a WARN() or am I too pedantic? :-p

> +	if (!ops || !ops->of_xlate || !priv) {
> +		dev_err(dev, "no PHY ops/PHY data provided\n");

likewise here.

> +		ret =3D -EINVAL;
> +		goto err0;
> +	}
> +
> +	if (!phy_class)
> +		phy_core_init();

why don't you setup the class on module_init ? Then this would be a
terrible error condition here :-)

> +static struct device_attribute phy_dev_attrs[] =3D {
> +	__ATTR(label, 0444, phy_name_show, NULL),
> +	__ATTR(phy_bind, 0444, phy_bind_show, NULL),

you could expose a human-readable 'type' string. BTW, how are you using
type ? USB2/USB3/etc ? Have you considered our OMAP5 SerDes pair which
are currently for USB3 and SATA (and could just as easily be used for
PCIe)

> +static void phy_release(struct device *dev)
> +{
> +	struct phy *phy;
> +
> +	phy =3D container_of(dev, struct phy, dev);
> +	dev_dbg(dev, "releasing '%s'\n", dev_name(dev));

how about dev_vdbg() ? I doubt anyone will be waiting for this
message... Just a thought

> +static int phy_core_init(void)
> +{
> +	if (phy_class)
> +		return 0;

Weird.. if you initialize the class here, why do you need to initialize
it during phy_create() ?

What's going on ? Also, module_init() will only be called once, why this
if (phy_class) check ?

--=20
balbi

--dFWYt1i2NyOo1oI9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRXDG6AAoJEIaOsuA1yqREAy4QAKlE3GiFkTahSneX9BblnvAa
tSMzIljqQ2vncPK4mgv1DVsVayClhOGdEqhx8R68wgFKKN7DeElLSZUKygxHEqJS
GahXSGx0onAMeUZnGM9JNlszr8+L/NtXNs+DPPdTiEfr+VhdZuzgHZqObW1aL6vf
3cq/8qGLtiqwcl6/v3KeSXVygdTey/kK5PJzbjbcKCYCtqNk0UyaijqiBSIiVFnr
To2PC1ONydQCq361C0AfRYMLxSdCgCtYcEwy8V6DaffVtHL6HFj0wYa14I9dmhNQ
Em94xu8LSaxHvA5RioHk8cHeOx7a7X1xrjdHDiV7O7wFoaGSmJ8CBm2sTDISL2Na
6DwTJ11Cc7RG/XDnaVlPDbnauOoUhyiH7mmkEwLeorG25nRqSsFt/GegGABFaK6C
7RjGwWvF/98qq3+w4DccMefpxO8Cuvbh+mrjXaR1bvcM+QC5PLfjkogMSxJguMGq
Y0DORjiWt2m138yXRT69R7qW9ATMH69dx3RxJyOLBnXeMjL+L7Z2e7XuQXULp+Vg
3o2FkWo4benrQ/Xj8wMnZOjGMWBnavCuPuy/veGu9DRwXFGtqJx78zqWuC/X87KK
nAxaFVVt/9/LqIN1ybuI3Yd7hLtOBK8ry1hR0+zgYSHeggF7jtabcAH5R9Pnmj/e
V21NYbXAUK4/xjiMDTMW
=9U5x
-----END PGP SIGNATURE-----

--dFWYt1i2NyOo1oI9--

--===============2926794252065107156==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devicetree-discuss mailing list
devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
https://lists.ozlabs.org/listinfo/devicetree-discuss

--===============2926794252065107156==--
