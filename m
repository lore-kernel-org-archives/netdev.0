From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next v3 1/4] net core: Add IFF_PROTO_DOWN support.
Date: Mon, 27 Apr 2015 23:05:04 -0700
Message-ID: <CAE4R7bBv350WnC4uEp7YZy7Jpq0zaTouWysgbSHXyktwTA9voA@mail.gmail.com>
References: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36355 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbD1GFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 02:05:04 -0400
Received: by qku63 with SMTP id 63so74622787qku.3
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 23:05:04 -0700 (PDT)
In-Reply-To: <1430156304-13187-2-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2015 at 10:38 AM,  <anuradhak@cumulusnetworks.com> wrote:
> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
>
> This patch introduces an IFF_PROTO_DOWN flag that can be used by
> user space applications to notify drivers that errors have been
> detected on the device.
>
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
> ---
>  include/uapi/linux/if.h |    4 ++++
>  net/8021q/vlan_dev.c    |    3 ++-
>  net/core/dev.c          |    2 +-
>  3 files changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> index 9cf2394..e263bd2 100644
> --- a/include/uapi/linux/if.h
> +++ b/include/uapi/linux/if.h
> @@ -66,6 +66,8 @@
>   * @IFF_LOWER_UP: driver signals L1 up. Volatile.
>   * @IFF_DORMANT: driver signals dormant. Volatile.
>   * @IFF_ECHO: echo sent packets. Volatile.
> + * @IFF_PROTO_DOWN: protocol is down on the interface. Can be toggled
> + *     through sysfs.

This comment is stale, right?  I didn't see any sysfs support in the patchset.
