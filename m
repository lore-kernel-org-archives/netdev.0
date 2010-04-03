From: Mark Ryden <markryde@gmail.com>
Subject: Re: [PATCH] ethtool: add names of newer Marvell chips
Date: Sat, 3 Apr 2010 10:20:40 +0300
Message-ID: <q2sdac45061004030020n28a1ad17p71ed2c074ebb6450@mail.gmail.com>
References: <20100402081632.5401cf2f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:51698 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab0DCHUn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 03:20:43 -0400
Received: by bwz1 with SMTP id 1so1912002bwz.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 00:20:40 -0700 (PDT)
In-Reply-To: <20100402081632.5401cf2f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> +       case 0xba:      printf("Yukon Ultra 2"); break;
> +       case 0xbc:      printf("Yukon Optima"); break;

What about 0xbb?
Is there ant reason for not using 0xbb for Yukon Optima?

Is it something with blackberry (bb)?  :-)
Mark


On Fri, Apr 2, 2010 at 6:16 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> Fill in names of newer chips.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>
> diff --git a/marvell.c b/marvell.c
> index 6696e0a..af38c21 100644
> --- a/marvell.c
> +++ b/marvell.c
> @@ -184,6 +184,9 @@ static void dump_mac(const u8 *r)
> =A0 =A0 =A0 =A0case 0xb6: =A0 =A0 =A0printf("Yukon-2 EC"); =A0 break;
> =A0 =A0 =A0 =A0case 0xb7: =A0 =A0 =A0printf("Yukon-2 FE"); =A0 break;
> =A0 =A0 =A0 =A0case 0xb8: =A0 =A0 =A0printf("Yukon-2 FE Plus"); break=
;
> + =A0 =A0 =A0 case 0xb9: =A0 =A0 =A0printf("Yukon Supreme"); break;
> + =A0 =A0 =A0 case 0xba: =A0 =A0 =A0printf("Yukon Ultra 2"); break;
> + =A0 =A0 =A0 case 0xbc: =A0 =A0 =A0printf("Yukon Optima"); break;
> =A0 =A0 =A0 =A0default: =A0 =A0 =A0 =A0printf("(Unknown)"); =A0 =A0br=
eak;
> =A0 =A0 =A0 =A0}
>
> --
> 1.6.3.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
