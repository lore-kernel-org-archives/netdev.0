From: Abraham Arce <abraham.arce.moreno@gmail.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH] net: Add batman-adv meshing protocol
Date: Tue, 20 Jul 2010 13:41:35 -0500
Message-ID: <AANLkTim4QSjgC2BbrEJEpefQahbkSgaRPPfJ-N0aPL-E@mail.gmail.com>
References: <1279291156-5297-2-git-send-email-sven.eckelmann@gmx.de>
	<201007201028.12470.sven.eckelmann@gmx.de>
	<20100720.095928.113690788.davem@davemloft.net>
	<201007202023.17883.lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: b.a.t.m.a.n@lists.open-mesh.org,
	David Miller <davem@davemloft.net>, sven.eckelmann@gmx.de,
	netdev@vger.kernel.org, siwu@hrz.tu-chemnitz.de
To: Marek Lindner <lindner_marek@yahoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52395 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761404Ab0GTSlg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 14:41:36 -0400
Received: by vws14 with SMTP id 14so595320vws.19
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 11:41:35 -0700 (PDT)
In-Reply-To: <201007202023.17883.lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Jul 20, 2010 at 1:23 PM, Marek Lindner <lindner_marek@yahoo.de>=
 wrote:
> On Tuesday, July 20, 2010 18:59:28 David Miller wrote:
>> Whoever you leave it to, this needs to be fixed up before this
>> code can be integrated. =A0So if those people are not active or
>> don't have time, you very much should consider the reality that
>> you might have to do these fixups yourself.
>
> No worries - we are quite alive and follow the discussion closely. Th=
e raised
> issues will be addressed pretty soon.
>
> @Sven: I think you do a great job integrating all those patches and t=
rees.
> Your helping hand would be really missed. =A0:)

Minor comments...

1. Is it ok to have a README in drivers directory? why not moving it
to Documentation/networking?
2. Compilation error, one extra arguments passed

- stats =3D (struct net_device_stats *)dev_get_stats(skb->dev, &temp);
+ stats =3D (struct net_device_stats *)dev_get_stats(skb->dev, &temp);

  LD      kernel/built-in.o
net/batman-adv/hard-interface.c: In function 'batman_skb_recv':
net/batman-adv/hard-interface.c:482: error: too many arguments to
function 'dev_get_stats'
make[2]: *** [net/batman-adv/hard-interface.o] Error 1
make[2]: *** Waiting for unfinished jobs....
make[1]: *** [net/batman-adv] Error 2
make: *** [net] Error 2

Best Regards
Abraham
