From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [RFC 0/2] be2net: Added functionality to support RoCE driver
Date: Wed, 7 Mar 2012 11:02:02 -0800
Message-ID: <CAL1RGDWqmdpU7U4robRs0J1xHPirW3ScmbycLNpZA--hO47mYg@mail.gmail.com>
References: <102ec66a-5bd6-4e64-81b2-87ea6111e466@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <102ec66a-5bd6-4e64-81b2-87ea6111e466-nbYkmrCdWxmgMrCBcu8zE0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

I would suggest that when the actual RoCE driver is posted, we
merge these 2 prerequisite patches + the driver through my tree,
to avoid the hassle of a dependency between my tree and Dave's
net-next tree.

(Assuming these patches are OK with Dave and everyone else...
they look pretty reasonable to me after a quick read)

When do you expect to post the actual RoCE driver?  If that's
going to be a while, another possibility is to just merge these
patches through net-next for 3.4, although I'm not sure about
how Dave feels about merging all this stuff without seeing what
will actually use it.

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
