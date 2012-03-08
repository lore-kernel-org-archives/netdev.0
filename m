From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC 0/2] be2net: Added functionality to support RoCE driver
Date: Wed, 7 Mar 2012 21:47:56 -0800
Message-ID: <88B766C272F2C64B944B21AD078333151C961A0E37@EXMAIL.ad.emulex.com>
References: <102ec66a-5bd6-4e64-81b2-87ea6111e466@exht1.ad.emulex.com>
 <CAL1RGDWqmdpU7U4robRs0J1xHPirW3ScmbycLNpZA--hO47mYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDWqmdpU7U4robRs0J1xHPirW3ScmbycLNpZA--hO47mYg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
=46rom: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org]=20
Sent: Thursday, March 08, 2012 12:32 AM
To: Pandit, Parav; David Miller
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Subject: Re: [RFC 0/2] be2net: Added functionality to support RoCE driv=
er

On Wed, Mar 7, 2012 at 9:47 AM,  <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
> From: Parav Pandit <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
>
> This patch is against roland's below Infiniband tree.
> http://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git
> Simiilar patch against netdev net-next tree will be made based on thi=
s patch.
>
> This patch adds functionality to support RoCE (RDMA over Ethernet) dr=
iver.
> - Detecting RoCE supported adapters and creating linked list of them.
> - Enabling 5 more MSIX vectors for RoCE functionality.
> - Calling registered callback functions of the RoCE driver
> =A0whenever new RoCE capable device is added/removed.
> - Notifying events to RoCE driver when interface is up or down.
> - Provides device specific details to RoCE driver for each roce devic=
e.
> - Provides low level mailbox command to be issued by RoCE driver
> =A0before it can have it own MQ.
>
> Parav Pandit (2):
> =A0be2net: Added function to issue mailbox cmd on MQ.
> =A0be2net: Added functionality to support RoCE driver

Great, I'm really excited to be getting another upstream driver.

I would suggest that when the actual RoCE driver is posted, we merge th=
ese 2 prerequisite patches + the driver through my tree, to avoid the h=
assle of a dependency between my tree and Dave's net-next tree.
[PP] There are minor differences in be2net driver in your tree and net-=
next tree. So if we are fine with the interface between RoCE driver and=
 NIC driver which is already available in this patch, then you can just=
 merge RoCE driver patch from  your tree to net-next tree. There will b=
e separate patch against net-next tree for NIC driver which will be alm=
ost similar to this one.

 (Assuming these patches are OK with Dave and everyone else...
they look pretty reasonable to me after a quick read)

When do you expect to post the actual RoCE driver?  If that's going to =
be a while, another possibility is to just merge these patches through =
net-next for 3.4, although I'm not sure about how Dave feels about merg=
ing all this stuff without seeing what will actually use it.
[PP] I was just waiting for comments on this RFC/PATCH to submit separa=
te patch for RoCE driver. But surely if RoCE driver patch helps review,=
 I can send it right away. I'll prepare the patch for Roland's tree and=
 send in few hours.

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
