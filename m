From: Nick Krause <xerofoify@gmail.com>
Subject: Re: solos-pci.c: Fix me
Date: Mon, 21 Jul 2014 13:42:01 -0400
Message-ID: <CAPDOMVh7cx57GtxHk-_tmorSWSj6xci-YkDrecdCLJfTANbHAQ@mail.gmail.com>
References: <CAPDOMVjnK=OF8mQrXbbgGUtCRJO8oG4+PQOETEcskNk=95GLrg@mail.gmail.com>
	<20140721091445.1ee700bb@thirdoffive.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140721091445.1ee700bb@thirdoffive.cmf.nrl.navy.mil>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 21, 2014 at 9:14 AM, chas williams - CONTRACTOR
<chas@cmf.nrl.navy.mil> wrote:
> On Sun, 20 Jul 2014 00:59:42 -0400
> Nick Krause <xerofoify@gmail.com> wrote:
>
>> Hey Chas,
>> There seems to be a fix me in this file in the function, solos_bh.
>> Is the default statement correct and I remove the fix me or
>> does it need to be rewritten.
>> Cheers Nick
>>
>
> I am afraid that I don't know enough about the solos hardware to know
> if it needs to be rewritten.  I gather the solos returns at least three
> kinds of packets, data, status and command.  If you wish to eliminate
> the FIXME comment, you could just write:
>
> @@ -850,8 +850,7 @@ static void solos_bh(unsigned long card_arg)
>                                 dev_kfree_skb_any(skb);
>                                 break;
>
> -                       case PKT_COMMAND:
> -                       default: /* FIXME: Not really, surely? */
> +                       default: /* PKT_COMMAND */
>                                 if (process_command(card, port, skb))
>                                         break;power
>                                 spin_lock(&card->cli_queue_lock);
>
> and be done with it since that will preserve existing behavior.


My only question then is this function causing bugs as is?
Cheers Nick
