From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next v4 RFC] ixgbe: Get and display the notifications from
 changes of the Rx vxlan UDP port
Date: Thu, 10 Oct 2013 13:07:58 +0300
Message-ID: <CAJZOPZJbfUjEbz_a+27tP8EieVJ+006VbVApQ+HrzkqmZRv1sw@mail.gmail.com>
References: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378286019-8719-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>, sassmann@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33201 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab3JJKH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 06:07:59 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so2385155pdj.29
        for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 03:07:59 -0700 (PDT)
In-Reply-To: <1378286019-8719-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 4, 2013 at 12:13 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Joseph Gasparakis <joseph.gasparakis@intel.com>

> +#ifdef CONFIG_VXLAN_MODULE
> +static void ixgbe_add_vxlan_port(struct net_device *netdev,
> +                                sa_family_t sa_family, __u16 port)
> +{
> +       netdev_info(netdev, ">>>>> Adding VXLAN port %d / protocol IPv%d\n",
> +                            port, sa_family == AF_INET ? 4 : 6);
> +}
> +


any deep reason under which the low level driver needs to define these
ndo's under special config directive?

Or.
