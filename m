From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 6 May 2009 16:39:25 -0600
Message-ID: <fa686aa40905061539t4fa463aehe56fdb64d053135d@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-3-git-send-email-wd@denx.de>
	<4A01F602.2010601@freescale.com> <20090506220954.5D3AF83420E8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Wood <scottwood@freescale.com>,
	John Rigby <jrigby@gmail.com>, linuxppc-dev@ozlabs.org,
	Piotr Ziecik <kosmo@semihalf.com>, Detlev Zundel <dzu@denx.de>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:58491 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754611AbZEFWjq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:39:46 -0400
Received: by yw-out-2324.google.com with SMTP id 5so236038ywb.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 15:39:46 -0700 (PDT)
In-Reply-To: <20090506220954.5D3AF83420E8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 4:09 PM, Wolfgang Denk <wd@denx.de> wrote:
> Dear Scott,
>
> in message <4A01F602.2010601@freescale.com> you wrote:
>>
>> All of the above is duplicative (with even the same names) of stuff =
in
>> asm/cpm.h. =A0Beyond just the duplication, what happens if both CPM2=
 and
>
> OK, I can try to reuse the definitions from that file.
>
>> 512x are enabled in the same kernel?
>
> Hm... both architectures look sufficiently different to me that I
> don't see sense in trying such a thing. Do you think that needs to be
> supported?

Yes!  :-)  It's not hard to do and it keeps the driver cleaner
(IMNSHO).  I don't think it is quite possible at the moment due to
cache coherency issues, but with Becky's recently merged dma ops
changes it should be fixable.

Cheers,
g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
