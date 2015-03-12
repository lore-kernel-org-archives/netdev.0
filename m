From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] vxlan: Correct path typo in comment
Date: Thu, 12 Mar 2015 16:44:28 +0300
Message-ID: <5501983C.50006@cogentembedded.com>
References: <1426125610-7903-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:37891 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbbCLNob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 09:44:31 -0400
Received: by labhs14 with SMTP id hs14so15350924lab.5
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 06:44:30 -0700 (PDT)
In-Reply-To: <1426125610-7903-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/12/2015 5:00 AM, Simon Horman wrote:

> Flags are used in the return path rather than the return patch.

    s/return/receive/?

> Fixes: af33c1adae1e ("vxlan: Eliminate dependency on UDP socket in transmit path")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
[...]

> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index eabd3a0..9564b77 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -130,7 +130,7 @@ struct vxlan_sock {
>   #define VXLAN_F_GBP			0x800
>   #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
>
> -/* Flags that are used in the receive patch. These flags must match in
> +/* Flags that are used in the receive path. These flags must match in
>    * order for a socket to be shareable
>    */
>   #define VXLAN_F_RCV_FLAGS		(VXLAN_F_GBP |			\

WBR, Sergei
