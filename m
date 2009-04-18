From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Probably a flaw in Linux rtl8139 driver FYI
Date: Sat, 18 Apr 2009 21:43:15 +0200
Message-ID: <49EA2D53.3080504@cosmosbay.com>
References: <528f811a0904170008q34b5cde1l810fb22f78eefaf7@mail.gmail.com>	 <528f811a0904170010w2b2c8b34j698b255331f78765@mail.gmail.com>	 <528f811a0904180540t15489826n99cf8143fe105463@mail.gmail.com>	 <49E9CF3C.2090308@cosmosbay.com> <528f811a0904180828i6b414a10p2dda1a7cbb79db87@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Tzungder Lin <tzungder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40469 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbZDRTn0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 15:43:26 -0400
In-Reply-To: <528f811a0904180828i6b414a10p2dda1a7cbb79db87@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tzungder Lin a =E9crit :
> Dear Eric,
>=20
> I agree with you at first.
> But after I checked the driver code, I think tp->cur_rx has been set
> to zero in rtl8139_init_ring() which has been executed before
> rtl8139_hw_start().
> So, it should be safe already.
> Thanks for your advice still.
> FYR

Very good ! Could you formally post the patch with your Signoff,
and make it applicable with "patch -p1" ?

(Please read Documentation/SubmittingPatches if you need some info)

Thanks


