From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 2/3] [RFC] ARM: shmobile: r7s72100: Add clock for
 r7s72100-gether
Date: Sun, 15 Dec 2013 23:18:51 +0300
Message-ID: <52AE0EAB.5040808@cogentembedded.com>
References: <1387095886-15163-1-git-send-email-horms+renesas@verge.net.au> <1387095886-15163-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:54441 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab3LOTSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 14:18:53 -0500
Received: by mail-la0-f53.google.com with SMTP id mc6so2301748lab.26
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 11:18:51 -0800 (PST)
In-Reply-To: <1387095886-15163-3-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/15/2013 11:24 AM, Simon Horman wrote:

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>   arch/arm/mach-shmobile/clock-r7s72100.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)

> diff --git a/arch/arm/mach-shmobile/clock-r7s72100.c b/arch/arm/mach-shmobile/clock-r7s72100.c
> index 7b457ae..7bce0c1 100644
> --- a/arch/arm/mach-shmobile/clock-r7s72100.c
> +++ b/arch/arm/mach-shmobile/clock-r7s72100.c
[...]
> @@ -145,9 +146,10 @@ struct clk div4_clks[DIV4_NR] = {
>   };
>
>   enum { MSTP47, MSTP46, MSTP45, MSTP44, MSTP43, MSTP42, MSTP41, MSTP40,
> -	MSTP33,	MSTP_NR };
> +	MSTP33,	MSTP74, MSTP_NR };

    Shouldn't MSTP74 be on a line of its own at the start of the *enum*?

WBR, Sergei
