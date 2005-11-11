From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP build fix
Date: Fri, 11 Nov 2005 10:41:38 -0800
Message-ID: <4374E5E2.70801@osdl.org>
References: <20051111094347.GA10876@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751002AbVKKSmT@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20051111094347.GA10876@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

>Recent TCP changes broke the build.
>
>Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
>
>diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
>index 4376814..b7d296a 100644
>--- a/net/ipv4/tcp_vegas.c
>+++ b/net/ipv4/tcp_vegas.c
>@@ -236,7 +236,7 @@ static void tcp_vegas_cong_avoid(struct 
> 			/* We don't have enough RTT samples to do the Vegas
> 			 * calculation, so we'll behave like Reno.
> 			 */
>-			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, cnt);
>+			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
> 		} else {
> 			u32 rtt, target_cwnd, diff;
> 
>  
>
Sorry, must have happened when juggling the test and release tree.
