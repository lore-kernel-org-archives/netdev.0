From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 11/11] Phonet: kernel documentation
Date: Tue, 23 Sep 2008 14:43:20 -0700
Message-ID: <20080923144320.fc1fc81c.randy.dunlap@oracle.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
	<1222098445-26175-11-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23202 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbYIWVne convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 17:43:34 -0400
In-Reply-To: <1222098445-26175-11-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Sep 2008 18:47:25 +0300 R=E9mi Denis-Courmont wrote:

> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  Documentation/networking/phonet.txt |  111 +++++++++++++++++++++++++=
++++++++++
>  1 files changed, 111 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/networking/phonet.txt
>=20
> diff --git a/Documentation/networking/phonet.txt b/Documentation/netw=
orking/phonet.txt
> new file mode 100644
> index 0000000..f3c72e0
> --- /dev/null
> +++ b/Documentation/networking/phonet.txt
> @@ -0,0 +1,111 @@
> +Linux Phonet protocol family
> +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> +
> +Introduction
> +------------
> +
> +Phonet is a packet protocol used by Nokia cellular modems for both I=
PC
> +and RPC. With the Linux Phonet socket family, Linux host processes c=
an
> +receive and send messages from/to the modem, or any other external
> +device attached to the modem. The modem takes care of routing.
> +
> +Phonet packets can be exchanged through various hardware connections
> +depending on the device, such as:
> +  - USB with the CDC Phonet interface,
> +  - infrared,
> +  - Bluetooth,
> +  - an RS232 serial port (with a dedicated "FBUS" line discipline),
> +  - the SSI bus with some TI OMAP processors.
> +
> +
> +Packets format
> +--------------
> +
> +Phonet packet have a common header as follow:

          packets

> +
> +  struct phonethdr {
> +    uint8_t  pn_media;  /* Media type (link-layer identifier) */
> +    uint8_t  pn_rdev;   /* Receiver device ID */
> +    uint8_t  pn_sdev;   /* Sender device ID */
> +    uint8_t  pn_res;    /* Resource ID or function */
> +    uint16_t pn_length; /* Big-endian message byte length (minus 6) =
*/
> +    uint8_t  pn_robj;   /* Receiver object ID */
> +    uint8_t  pn_sobj;   /* Sender object ID */
> +  };
> +
> +The device ID is split: the 6 higher order bits consitutes the devic=
e

                                 higher-order bits constitute

> +address, while the 2 lower order bits are used for multiplexing, as =
are

                        lower-order

> +the 8-bits object identifiers. As such, Phonet can be considered as =
a

       8-bit

> +network layer with 6 bits of address space and 10 bits for transport
> +protocol (much like port numbers in IP world).
> +
> +The modem always has address number zero. Each other device has a it=
s

                                             All other devices have the=
ir
> +own 6-bits address.

   own 6-bit address.


---
~Randy
