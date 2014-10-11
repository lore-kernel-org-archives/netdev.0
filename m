From: Walter Lozano <walter@vanguardiasur.com.ar>
Subject: Re: [Nios2-dev] [PATCH net-next 0/2] Altera TSE with no PHY
Date: Sat, 11 Oct 2014 19:24:13 -0300
Message-ID: <CABxpGwCL4MSoqutnFL9ebATwe4aug7ciwyR50HO5T1R8XPURgg@mail.gmail.com>
References: <1412359741-8423-1-git-send-email-walter@vanguardiasur.com.ar>
	<1412974007001.77871@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"tobias.klauser@gmail.com" <tobias.klauser@gmail.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"guido@vanguardiasur.com.ar" <guido@vanguardiasur.com.ar>
To: Matthew Gerlach <mgerlach@opensource.altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:59934 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147AbaJKWYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 18:24:14 -0400
Received: by mail-oi0-f52.google.com with SMTP id a3so9980547oib.11
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 15:24:13 -0700 (PDT)
In-Reply-To: <1412974007001.77871@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthew,

Thanks for your testing. I'm glad to hear that I didn't break
anything. Most of my testing
was done with a custom board with a SFP transceiver.

Regards,

Walter

On Fri, Oct 10, 2014 at 5:46 PM, Matthew Gerlach
<mgerlach@opensource.altera.com> wrote:
> Hi Walter,
>
> I've examined your patch, and it makes sense to me.  I tested your patch again the TSE example design, and it did not break anything.
>
> Thanks,
> Matthew Gerlach
> ________________________________________
> From: nios2-dev-bounces@lists.rocketboards.org <nios2-dev-bounces@lists.rocketboards.org> on behalf of Walter Lozano <walter@vanguardiasur.com.ar>
> Sent: Friday, October 3, 2014 11:08 AM
> To: netdev@vger.kernel.org
> Cc: f.fainelli@gmail.com; tobias.klauser@gmail.com; vbridgers2013@gmail.com; nios2-dev@lists.rocketboards.org; davem@davemloft.net; guido@vanguardiasur.com.ar
> Subject: [Nios2-dev] [PATCH net-next 0/2] Altera TSE with no PHY
>
> In some scenarios there is no PHY chip present, for example in optical links.
> This serie of patches moves PHY get addr and MDIO create to a new function and
> avoids PHY and MDIO probing in these cases.
>
> Walter Lozano (2):
>   Altera TSE: Move PHY get addr and MDIO create
>   Altera TSE: Add support for no PHY
>
>  drivers/net/ethernet/altera/altera_tse_main.c |   65 +++++++++++++++++--------
>  1 file changed, 44 insertions(+), 21 deletions(-)
>
> --
> 1.7.10.4
>
> _______________________________________________
> Nios2-dev mailing list
> Nios2-dev@lists.rocketboards.org
> http://lists.rocketboards.org/cgi-bin/mailman/listinfo/nios2-dev



-- 
Walter Lozano, VanguardiaSur
www.vanguardiasur.com.ar
