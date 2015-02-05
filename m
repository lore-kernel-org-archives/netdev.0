From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 14/29] net: vrf: Introduce vrf header file
Date: Thu, 05 Feb 2015 14:44:48 +0100
Message-ID: <54D373D0.40405@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-15-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:65115 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757710AbbBENou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:44:50 -0500
Received: by mail-wg0-f46.google.com with SMTP id l2so7654125wgh.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:44:49 -0800 (PST)
In-Reply-To: <1423100070-31848-15-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> Defines for min and max vrf id and helpers for examining
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>   include/net/vrf.h | 36 ++++++++++++++++++++++++++++++++++++
>   1 file changed, 36 insertions(+)
>   create mode 100644 include/net/vrf.h
>
> diff --git a/include/net/vrf.h b/include/net/vrf.h
> new file mode 100644
> index 000000000000..67bc2e465661
> --- /dev/null
> +++ b/include/net/vrf.h
> @@ -0,0 +1,36 @@
> +#ifndef _VRF_H_
> +#define _VRF_H_
> +
> +#define VRF_BITS	12
> +#define VRF_MIN		1
> +#define VRF_MAX		((1 << VRF_BITS) - 1)
> +#define VRF_MASK	VRF_MAX
> +
> +#define VRF_DEFAULT	1
> +#define VRF_ANY		0xffff
It could be useful to expose this value to userland.
