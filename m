From: Roger While <simrw@sim-basis.de>
Subject: Re: [PATCH] fix limited slow start bug
Date: Sun, 25 Feb 2007 09:55:34 +0100
Message-ID: <6.1.1.1.2.20070225095105.049cd960@192.168.6.12>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout03.sul.t-online.com ([194.25.134.81]:53776 "EHLO
	mailout03.sul.t-online.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932956AbXBYI4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 03:56:00 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Dave M wrote :
>diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>index 415193e..18a468d 100644
>--- a/include/linux/tcp.h
>+++ b/include/linux/tcp.h
>@@ -302,7 +302,7 @@ struct tcp_sock {
>         u32     snd_ssthresh;   /* Slow start size threshold            */
>         u32     snd_cwnd;       /* Sending congestion window            */
>         u16     snd_cwnd_cnt;   /* Linear increase counter              */
>-       u16     snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
>+       u32     snd_cwnd_clamp; /* Do not allow snd_cwnd to grow above this */
>         u32     snd_cwnd_used;
>         u32     snd_cwnd_stamp;

Was anything done about size/member alignment of struct tcp_sock per
mail from last year  -
http://marc.theaimsgroup.com/?l=linux-netdev&m=114318857102290&w=2

(I have no idea what current size is)


