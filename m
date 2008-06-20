From: =?ISO-8859-1?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: Re: [PATCH] net: via-velocity.c fix sleep-with-spinlock bug during
 MTU change
Date: Fri, 20 Jun 2008 18:50:55 +0200
Message-ID: <485BDFEF.2090307@e-teleport.net>
References: <20080604215909.GA17446@electric-eye.fr.zoreil.com> <20080614212341.GA12976@electric-eye.fr.zoreil.com> <4856DA62.7080803@e-teleport.net> <20080617214538.GA6388@electric-eye.fr.zoreil.com> <48584AA4.8040801@e-teleport.net> <48593E35.1010409@e-teleport.net> <20080618201012.GA4019@electric-eye.fr.zoreil.com> <48598784.40306@e-teleport.net> <20080619204312.GA2160@electric-eye.fr.zoreil.com> <485B8542.7060204@e-teleport.net> <20080620103910.GA21227@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arjan van de Ven <arjan@infradead.org>, alan@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:40015 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753892AbYFTQvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 12:51:03 -0400
In-Reply-To: <20080620103910.GA21227@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rancois Romieu a =E9crit :
> S=E9guier R=E9gis <rseguier@e-teleport.net> :
> [...]
>  =20
>> But if I generate a paquet with a size more than around 3825, the dr=
iver=20
>> don't send it and no paquet is send after, work again after an inter=
face=20
>> down/up and until no paquet > 3825.
>>    =20
>
> Does it qualify as a regression ?
>
>  =20
I couldn't say yes now.

To be honest, I never test mtu > 1500 with this driver before.

This can be detected before with the difficulty of mtu change?

I'll test the driver before patch with a bigger MTU. (i'll try to do=20
this next week)

--=20
R=E9gis
