From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH v1 0/2] basic ioctl support for netlink sockets
Date: Mon, 21 Mar 2016 10:43:58 -0700
Message-ID: <CAG88wWYSzNFPe=9HGy9YUJFcDyk_ZNndoxyz=+=texYmV22_Yg@mail.gmail.com>
References: <1458259436-85275-1-git-send-email-ddecotig@gmail.com> <20160320.133122.908035685889835834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nikolay@cumulusnetworks.com, "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	nicolas.dichtel@6wind.com, andrew@lunn.ch, hadarh@mellanox.com,
	ecree@solarflare.com, john.r.fastabend@intel.com,
	Herbert Xu <herbert@gondor.apana.org.au>, tgraf@suug.ch,
	daniel@iogearbox.net, chamaken@gmail.com, fw@strlen.de,
	dh.herrmann@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35621 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757539AbcCURok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 13:44:40 -0400
Received: by mail-wm0-f44.google.com with SMTP id l68so120257298wml.0
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 10:44:39 -0700 (PDT)
In-Reply-To: <20160320.133122.908035685889835834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sent updated version. commit description should have the details. what
we are doing there is mimic what some others are doing, such as udp.c:
when returning -ENOIOCTLCMD, net/core would fallback to dev_ioctl,
which implements the NIC driver ioctls, which include ethtool ioctl.

On Sun, Mar 20, 2016 at 10:31 AM, David Miller <davem@davemloft.net> wrote:
> From: David Decotigny <ddecotig@gmail.com>
> Date: Thu, 17 Mar 2016 17:03:54 -0700
>
>> This removes the requirement that ethtool be tied to the support
>> of a specific L3 protocol, also updates a comment.
>
> You're adding an ioctl handler to netlink sockets, and it is not
> at all apparent to me how this influences ethtool handling at all.
>
> Therefore you have to explain this here and in your commit message.
