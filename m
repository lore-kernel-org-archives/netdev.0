From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] gre: Fix GREv4 TCPv6 segmentation.
Date: Thu, 02 May 2013 20:00:55 -0700
Message-ID: <1367550055.29805.14.camel@edumazet-glaptop>
References: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:56265 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762679Ab3ECDA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 23:00:58 -0400
Received: by mail-da0-f53.google.com with SMTP id o9so591754dan.40
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 20:00:57 -0700 (PDT)
In-Reply-To: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 19:14 -0700, Pravin B Shelar wrote:
> For ipv6 traffic, GRE can generate packet with strange GSO
> bits, e.g. ipv4 packet with SKB_GSO_TCPV6 flag set.  Therefore
> following patch relaxes check in inet gso handler to allow
> such packet for segmentation.
> This patch also fixes wrong skb->protocol set that was done in
> gre_gso_segment() handler.
> 
> Reported-by: Steinar H. Gunderson <sesse@google.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Same issue exist in 3.8.
> ---

Thanks a lot.

I did a quick test and it appears to fix the problem.

Acked-by: Eric Dumazet <edumazet@google.com>
