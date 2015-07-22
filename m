From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 1/3] tcp: replace cnt & rtt with struct
 in pkts_acked()
Date: Wed, 22 Jul 2015 07:46:50 +0200
Message-ID: <1437544010.16824.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437538896-1330704-1-git-send-email-brakmo@fb.com>
	 <1437538896-1330704-2-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37849 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbGVFqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 01:46:53 -0400
Received: by wibud3 with SMTP id ud3so155070773wib.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 22:46:53 -0700 (PDT)
In-Reply-To: <1437538896-1330704-2-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-21 at 21:21 -0700, Lawrence Brakmo wrote:
> Replace 2 arguments (cnt and rtt) in the congestion control modules'
> pkts_acked() function with a struct. This will allow adding more
> information without having to modify existing congestion control
> modules (tcp_nv in particular needs bytes in flight when packet
> was sent).
> 
> This was proposed by Neal Cardwell in his comments to the tcp_nv patch.

Are you sure Neal suggested to pass a struct as argument ?

It was probably a struct pointer instead.
