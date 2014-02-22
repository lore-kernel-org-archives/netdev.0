From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH] af_packet: Add PACKET_FANOUT_QM documentation
Date: Sat, 22 Feb 2014 10:44:40 +0100
Message-ID: <53087188.9080408@gmail.com>
References: <1390911375-5784-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, andi@firstfloor.org, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>, linux-man@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f44.google.com ([209.85.214.44]:39924 "EHLO
	mail-bk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaBVLES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 06:04:18 -0500
In-Reply-To: <1390911375-5784-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/28/2014 01:16 PM, Neil Horman wrote:
> Recently added a new fanout mode of operation to packet sockets.  Document it
> here

Thanks, Neil. Applied.

This new mode is ne win 3.14, right?

Cheers,

Michael


> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: mtk.manpages@gmail.com
> CC: andi@firstfloor.org
> CC: netdev@vger.kernel.org
> ---
>  man7/packet.7 | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/man7/packet.7 b/man7/packet.7
> index 93f91e9..6e145dc 100644
> --- a/man7/packet.7
> +++ b/man7/packet.7
> @@ -296,6 +296,8 @@ processes all data on a single socket, moves to the next when one
>  becomes backlogged.
>  .BR PACKET_FANOUT_RND
>  selects the socket using a pseudo-random number generator.
> +.BR PACKET_FANOUT_QM
> +selects the socket using the recorded queue_mapping of the received skb.
>  
>  Fanout modes can take additional options.
>  IP fragmentation causes packets from the same flow to have different
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
