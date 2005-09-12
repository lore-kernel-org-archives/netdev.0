From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH  5/12] Add descriptions to constants
Date: Mon, 12 Sep 2005 18:41:53 +0200
Message-ID: <200509121841.53666.netdev@axxeo.de>
References: <20050911221904.GA9301@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
In-Reply-To: <20050911221904.GA9301@linux-mips.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ralf,

Ralf Baechle DL5RB wrote:
> Comment the names used for the AX.25 state machine.

What about making it even more useful by aliasing the enum elements?

> Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>
>
>  include/net/ax25.h |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
>
> Index: linux-cvs/include/net/ax25.h
> ===================================================================
> --- linux-cvs.orig/include/net/ax25.h
> +++ linux-cvs/include/net/ax25.h
> @@ -97,11 +97,11 @@
>  /* Define Link State constants. */
>
>  enum {
> -	AX25_STATE_0,
> -	AX25_STATE_1,
> -	AX25_STATE_2,
> -	AX25_STATE_3,
> -	AX25_STATE_4
> +	AX25_STATE_0,			/* Listening */
    +  AX25_STATE_LISTENING = AX25_STATE_0,
> +	AX25_STATE_1,			/* SABM sent */
    +  AX25_STATE_SABM_SENT = AX25_STATE_1,
> +	AX25_STATE_2,			/* DISC sent */
    +  AX25_STATE_DISC_SENT = AX25_STATE_2,
> +	AX25_STATE_3,			/* Established */
    +  AX25_STATE_ESTABLISHED = AX25_STATE_3,
> +	AX25_STATE_4			/* Recovery */
    +  AX25_STATE_RECOVERY = AX25_STATE_4,
>  };

That would not break backward compatibility and now the state machine can be
self explanatory :-)


Regards

Ingo Oeser

