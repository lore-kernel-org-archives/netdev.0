From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] add GENEVE netdev tunnel driver
Date: Fri, 8 May 2015 12:32:48 -0700
Message-ID: <20150508123248.69994aa1@urahara>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33972 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230AbbEHTco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 15:32:44 -0400
Received: by pacyx8 with SMTP id yx8so57461649pac.1
        for <netdev@vger.kernel.org>; Fri, 08 May 2015 12:32:43 -0700 (PDT)
In-Reply-To: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  8 May 2015 13:20:52 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> This 5-patch kernel series adds a netdev implementation of a GENEVE
> tunnel driver, and the single iproute2 patch enables creation and
> such for those netdevs.  This makes use of the existing GENEVE
> infrastructure already used by the OVS code.  The net/ipv4/geneve.c
> file is renamed as net/ipv4/geneve_core.c as part of these changes.
> 
>  drivers/net/Kconfig            |   14 +
>  drivers/net/Makefile           |    1 
>  drivers/net/geneve.c           |  550 +++++++++++++++++++++++++++++++++++++++++
>  include/net/geneve.h           |    5 
>  include/uapi/linux/if_link.h   |    9 
>  net/ipv4/Kconfig               |    4 
>  net/ipv4/Makefile              |    2 
>  net/ipv4/geneve.c              |    6 
>  net/ipv4/geneve_core.c         |    4 
>  net/openvswitch/Kconfig        |    2 
>  net/openvswitch/vport-geneve.c |    5 
>  11 files changed, 585 insertions(+), 17 deletions(-)
> 
> The overall structure of the GENEVE netdev driver is strongly
> influenced by the VXLAN netdev driver.  This is not surprising, as the
> two drivers are intended to serve similar purposes.  As development of
> the GENEVE driver continues, it is likely that those similarities will
> grow stronger.  This will include both simple configuration options
> (e.g. TOS and TTL settings) and new control plane support.

Look good. Thanks.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
