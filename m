From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 3/4] net: Add IPv6 support to VRF device
Date: Wed, 7 Oct 2015 11:42:38 -0700
Message-ID: <CAHA+R7Pvt7ZiUMnseimJYV=PT2ArYu9VOpvp2qz00CDem_TM2Q@mail.gmail.com>
References: <1444236640-2410-1-git-send-email-dsa@cumulusnetworks.com>
	<1444236640-2410-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Ahern <dsahern@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:33826 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752473AbbJGSmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:42:39 -0400
Received: by ykdg206 with SMTP id g206so26721463ykd.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 11:42:38 -0700 (PDT)
In-Reply-To: <1444236640-2410-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 9:50 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> Add support for IPv6 to VRF device driver. Implemenation parallels what
> has been done for IPv4.
[...]
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index b9ebd0d18a52..c878a0bc2137 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -300,6 +300,7 @@ config NET_VRF
>         tristate "Virtual Routing and Forwarding (Lite)"
>         depends on IP_MULTIPLE_TABLES && IPV6_MULTIPLE_TABLES
>         depends on NET_L3_MASTER_DEV
> +       depends on IPV6

So vrf will stop functioning without IPV6? This doesn't look correct...
