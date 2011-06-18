From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 14/14] SIWv2: Documentation: siw.txt
Date: Sat, 18 Jun 2011 19:56:24 +0200
Message-ID: <BANLkTimggAAHtOrrUdh_1WLRztUgk-wJbQ@mail.gmail.com>
References: <1308228174-22788-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308228174-22788-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 2:42 PM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> w=
rote:
> ---
> =A0Documentation/networking/siw.txt | =A0156 ++++++++++++++++++++++++=
++++++++++++++
> =A01 files changed, 156 insertions(+), 0 deletions(-)
> =A0create mode 100644 Documentation/networking/siw.txt
>
> diff --git a/Documentation/networking/siw.txt b/Documentation/network=
ing/siw.txt
> new file mode 100644
> index 0000000..805e21b
> --- /dev/null
> +++ b/Documentation/networking/siw.txt
> @@ -0,0 +1,156 @@
> +SoftiWARP: Software iWARP kernel driver module.
> +
> +General
> +-------
> +SoftiWARP (siw) implements the iWARP protocol suite (MPA/DDP/RDMAP,
> +IETF-RFC 5044/5041/5040) completely in software as a Linux kernel mo=
dule.
> +siw runs on top of TCP kernel sockets and exports the Linux kernel i=
bverbs
> +RDMA interface. siw interfaces with the iwcm connection manager.
> +
> +
> +Transmit Path
> +-------------
> +If a send queue (SQ) work queue element gets posted, siw tries to se=
nd
> +it directly out of the application context. If the SQ was non-empty,
> +SQ processing is done asynchronously by a kernel worker thread. This
> +thread gets scheduled if the TCP socket signals new write space to
> +be available. If during send operation the socket send space becomes
> +exhausted, SQ processing is abandoned until new socket write space
> +becomes available.

It seems like some information is missing in the above:
- That the siw kernel module creates an iWARP device for each Ethernet
interface found but not for other network interfaces that support the
family of IP protocols.
- Whether or not such an iWARP device is created for Ethernet
interfaces instantiated after the siw kernel module has been loaded.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
