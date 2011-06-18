From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 01/14] SIWv2: Kconfig and Makefile
Date: Sat, 18 Jun 2011 19:58:07 +0200
Message-ID: <BANLkTikKdsztdkFB1UJjoSUjnj8=D4VhzA@mail.gmail.com>
References: <1308228106-22565-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308228106-22565-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 2:41 PM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> w=
rote:
> diff --git a/drivers/infiniband/hw/siw/Kconfig b/drivers/infiniband/h=
w/siw/Kconfig
> new file mode 100644
> index 0000000..6beff23
> --- /dev/null
> +++ b/drivers/infiniband/hw/siw/Kconfig
> @@ -0,0 +1,14 @@
> +config INFINIBAND_SOFTIWARP
> + =A0 =A0 =A0 tristate "Software iWARP Stack (EXPERIMENTAL)"
> + =A0 =A0 =A0 depends on INET && EXPERIMENTAL

No dependency on INFINIBAND ?

> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Kernel Software Implementation of the iWARP protoco=
l stack
> +
> + =A0 =A0 =A0 =A0 This driver implements the iWARP protocol stack in =
software
> + =A0 =A0 =A0 =A0 and interfaces with in-kernel TCP/IP as well as the=
 OFED
> + =A0 =A0 =A0 =A0 verbs interfaces.
> +
> + =A0 =A0 =A0 =A0 Please send feedback to <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>.
> +
> + =A0 =A0 =A0 =A0 To compile this driver as a module, choose M here: =
the module
> + =A0 =A0 =A0 =A0 will be called siw.

Seems like a good idea to me to mention that an iWARP device is
created automatically to each Ethernet interface found at the time siw
is loaded.

Also, I think author information should be added to MAINTAINERS file
instead of Kconfig.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
