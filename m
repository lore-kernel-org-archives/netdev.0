From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Tue, 03 Jan 2012 09:06:17 +0100
Message-ID: <1325577977.2549.12.camel@edumazet-laptop>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
	 <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com>
	 <CAL8zT=h=mDNiDRVDo=jjcCjkyRGZ79iQiQLT3ZVRLb2PuC2ugg@mail.gmail.com>
	 <CAL8zT=htsVAJotATQ5Lqidea5dEqCkZOgTT6t4-fFjjDzcVviw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37661 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab2ACIGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 03:06:21 -0500
Received: by wibhm6 with SMTP id hm6so8880241wib.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 00:06:20 -0800 (PST)
In-Reply-To: <CAL8zT=htsVAJotATQ5Lqidea5dEqCkZOgTT6t4-fFjjDzcVviw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 08:36 +0100, Jean-Michel Hautbois a =C3=
=A9crit :

> After looking to the results, I can't see really bad values or
> anything which would explain such a behaviour...

no tcp problems, so your board seems to be slow

> Maybe is there some limits in the driver ? My board is a leopardboard=
 (dm368).
> Any idea ?

Just to have any idea of the inter frame timings, could you post the
~200 first frames taken on x86 ?

tcpdump -p -n -s 0 -i eth0 host arm_ip -c 200
