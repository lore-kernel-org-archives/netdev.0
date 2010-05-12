From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: avoid TX timeout when stopping device
Date: Wed, 12 May 2010 14:37:43 +0200
Message-ID: <1273667863.2621.28.camel@edumazet-laptop>
References: <20100512110921.0e3f45fc@dhcp-lab-109.englab.brq.redhat.com>
	 <1273656458.2621.22.camel@edumazet-laptop>
	 <20100512125815.0dad8ad0@dhcp-lab-109.englab.brq.redhat.com>
	 <1273663155.5948.7.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>,
	Matthew Carlson <mcarlson@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:36461 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab0ELMhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 08:37:47 -0400
Received: by wwi18 with SMTP id 18so758937wwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 05:37:46 -0700 (PDT)
In-Reply-To: <1273663155.5948.7.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 mai 2010 =C3=A0 14:19 +0300, Eilon Greenstein a =C3=A9cr=
it :

> Eric,
>=20
> I thought that your 1ae5dc342ac78d7a42965fd1f323815f6f5ef2c1 commit t=
ook
> care of trans_start, right? Well, actually the commit that made it
> possible to remove the trans_start manipulation.

Its only part of the (huge) job, started last year with 10GB and GB
nics.

My intent was to take care of not touching dev->trans_start in
start_xmit() method, then take care of other cases later.



