From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [2.6 patch] unexport sysctl_tcp_tso_win_divisor
Date: Wed, 30 Jan 2008 23:05:35 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801302303300.5832@kivilampi-30.cs.helsinki.fi>
References: <20080130200232.GU29368@does.not.exist>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-238529698-1201727135=:5832"
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51232 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbYA3VFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 16:05:47 -0500
In-Reply-To: <20080130200232.GU29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-238529698-1201727135=:5832
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 30 Jan 2008, Adrian Bunk wrote:

> This patch removes the no longer used 
> EXPORT_SYMBOL(sysctl_tcp_tso_win_divisor).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
>
> ---
> 4884e7997ba5f63f2efeaeead21ed2768fb3f4de 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 89f0188..ed750f9 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2564,5 +2564,4 @@ EXPORT_SYMBOL(tcp_connect);
>  EXPORT_SYMBOL(tcp_make_synack);
>  EXPORT_SYMBOL(tcp_simple_retransmit);
>  EXPORT_SYMBOL(tcp_sync_mss);
> -EXPORT_SYMBOL(sysctl_tcp_tso_win_divisor);
>  EXPORT_SYMBOL(tcp_mtup_init);

...yes, results from the recent move of tcp_is_cwnd_limited() away from 
tcp.h.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
---696243703-238529698-1201727135=:5832--
