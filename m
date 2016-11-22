From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] iproute2: Nr. of packets and octets for macsec tx stats
 were swapped.
Date: Tue, 22 Nov 2016 14:56:22 +0100
Message-ID: <20161122135622.GA23112@bistromath.localdomain>
References: <OFDC737720.EA272892-ONC1258073.00458CA2-C1258073.0049AC0D@continental-corporation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Daniel.Hopf@continental-corporation.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50048 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932305AbcKVN4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 08:56:25 -0500
Content-Disposition: inline
In-Reply-To: <OFDC737720.EA272892-ONC1258073.00458CA2-C1258073.0049AC0D@continental-corporation.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

Thanks for fixing this. I noticed it some time ago but it seems
I forgot to send the patch :(

Acked-by: Sabrina Dubroca <sd@queasysnail.net>


Your subject line should be:

Subject: [PATCH iproute2] macsec: Nr.of packets and octets for macsec tx stats were swapped.

with "iproute2" between the brackets.

2016-11-22, 14:24:40 +0100, Daniel.Hopf@continental-corporation.com wrote:
> Signed-off-by: Daniel Hopf <daniel.hopf@continental-corporation.com>
> ---
>  ip/ipmacsec.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
> index c9252bb..aa89a00 100644
> --- a/ip/ipmacsec.c
> +++ b/ip/ipmacsec.c
> @@ -634,10 +634,10 @@ static void print_one_stat(const char **names, 
> struct rtattr **attr, int idx,
>  }
> 
>  static const char *txsc_stats_names[NUM_MACSEC_TXSC_STATS_ATTR] = {
> -       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = 
> "OutOctetsProtected",
> -       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = 
> "OutOctetsEncrypted",
> -       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
> "OutPktsProtected",
> -       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
> "OutPktsEncrypted",
> +       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_PROTECTED] = "OutPktsProtected",
> +       [MACSEC_TXSC_STATS_ATTR_OUT_PKTS_ENCRYPTED] = "OutPktsEncrypted",
> +       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_PROTECTED] = 
> "OutOctetsProtected",
> +       [MACSEC_TXSC_STATS_ATTR_OUT_OCTETS_ENCRYPTED] = 
> "OutOctetsEncrypted",
>  };

Your patch was corrupted, probably by your email client, you have
extra newlines everywhere.
Can you send a v2 of this patch? Thanks!

-- 
Sabrina
