From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [af-packet 1/2] Enhance af-packet to provide (near
 zero)lossless packet capture functionality.
Date: Wed, 8 Jun 2011 09:03:05 -0700
Message-ID: <20110608090305.370f5857@nehalam.ftrdhcpuser.net>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	<1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, kaber@trash.net, johann.baudy@gnu-log.net,
	Chetan Loke <lokec@ccs.neu.edu>
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60072 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754402Ab1FHRwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 13:52:18 -0400
In-Reply-To: <1307502786-1396-2-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  7 Jun 2011 23:13:05 -0400
Chetan Loke <loke.chetan@gmail.com> wrote:

> --- a/include/linux/if_packet.h
> +++ b/include/linux/if_packet.h
> @@ -24,7 +24,7 @@ struct sockaddr_ll {
>  #define PACKET_HOST		0		/* To us		*/
>  #define PACKET_BROADCAST	1		/* To all		*/
>  #define PACKET_MULTICAST	2		/* To group		*/
> -#define PACKET_OTHERHOST	3		/* To someone else 	*/
> +#define PACKET_OTHERHOST	3		/* To someone else	*/

Useless whitespace change in patch. It makes sense to review the resulting
diff and avoid this kind of stuff creeping in.
