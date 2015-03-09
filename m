From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/4] net: refactor IPv4 and IPv6 fragmentation
 APIs
Date: Mon, 09 Mar 2015 08:05:39 -0700
Message-ID: <1425913539.8261.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
	 <1425888098-21875-4-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:38167 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbbCIPFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 11:05:42 -0400
Received: by iecrl12 with SMTP id rl12so21132047iec.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 08:05:41 -0700 (PDT)
In-Reply-To: <1425888098-21875-4-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 01:01 -0700, Andy Zhou wrote:

> +EXPORT_SYMBOL(ip_fragment_mtu);
> +
> +/*This IP datagram is too large to be sent in one piece.  Break it up into
> + *smaller pieces (each of size equal to IP header plus
> + *a block of the data of the original IP data part) that will yet fit in a
> + *single device frame, and queue such a frame for sending.
> + */

->

+/* This IP datagram is too large to be sent in one piece.  Break it up into
+ * smaller pieces (each of size equal to IP header plus
+ * a block of the data of the original IP data part) that will yet fit in a
+ * single device frame, and queue such a frame for sending.
+ */
