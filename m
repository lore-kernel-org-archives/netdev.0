From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH man-pages] man: packet.7: document fanout, ring and auxiliary
 options
Date: Fri, 06 Dec 2013 20:54:32 +0100
Message-ID: <52A22B78.8070109@redhat.com>
References: <52A1F7D7.6040305@redhat.com> <1386350329-32723-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
	netdev@vger.kernel.org
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758042Ab3LFTyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 14:54:39 -0500
In-Reply-To: <1386350329-32723-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2013 06:18 PM, Willem de Bruijn wrote:
> The packet socket manual page does not list all socket options.
>
> This patch adds descriptions of the common packet socket options
>    PACKET_AUXDATA, PACKET_FANOUT, PACKET_RX_RING, PACKET_STATISTICS,
>    PACKET_TX_RING
>
> and the ring-specific options
>    PACKET_LOSS, PACKET_RESERVE, PACKET_TIMESTAMP, PACKET_VERSION
>
> It does not yet add descriptions for
>    PACKET_COPY_THRESH, PACKET_HDRLEN, PACKET_ORIGDEV,
>    PACKET_TX_HAS_OFF, PACKET_TX_TIMESTAMP, PACKET_VNET_HDR
>
> It tries to balance being informative with exposing kernel detail
> that is unlikely to be used by most readers or that may change
> frequently. For implementation details, the manpage points to the
> documentation in kernel Documentation/networking. Let me know if
> options should be added or removed.
>
> Source: PACKET_FANOUT, PACKET_RX_RING and PACKET_VERSION are in
> /tools/testing/net/psock_fanout.c in the latest Linux kernel source
> tree. PACKET_STATISTICS was in the first version of that test.
> PACKET_TX_RING I have used elsewhere. The other options are based
> on reading kernel code.
>
>   [Very minor fixups. -dborkman]
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

I went over the man page again, and it looks good to me.

Great work and thanks for following up Willem!
