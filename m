From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH 0/5] GTP: Fine-tuning for some function implementations
Date: Thu, 26 Jan 2017 12:14:07 +0100 (CET)
Message-ID: <1065111512.617676.1485429247267.JavaMail.zimbra@tpip.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        laforge <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        pablo <pablo@netfilter.org>, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:36031 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750877AbdAZLOK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 06:14:10 -0500
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Markus,

----- On Jan 26, 2017, at 11:15 AM, SF Markus Elfring elfring@users.sourceforge.net wrote:

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 26 Jan 2017 11:10:01 +0100
> 
> A few update suggestions were taken into account
> from static source code analysis.
> 
> Markus Elfring (5):
>  Use kmalloc_array() in gtp_hashtable_new()
>  Improve another size determination in ipv4_pdp_add()
>  Adjust 12 checks for null pointers
>  Rename jump labels in gtp_encap_enable()
>  Rename jump labels in gtp_hashtable_new()

Looks good to me, for all the above:

Reviewed-by: Andreas Schultz <aschultz@tpip.net>

Andreas

> 
> drivers/net/gtp.c | 46 ++++++++++++++++++++++++----------------------
> 1 file changed, 24 insertions(+), 22 deletions(-)
> 
> --
> 2.11.0
