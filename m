From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 4/5] ifb: add multiqueue support
Date: Tue, 14 Dec 2010 07:46:41 +0800
Message-ID: <AANLkTikGpX_nYZ4Ubg7ArRk=-YfkrTxeALX=JPv7o5h-@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-4-git-send-email-xiaosuo@gmail.com> <1292259931.2759.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:57128 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755866Ab0LMXrC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 18:47:02 -0500
Received: by fxm18 with SMTP id 18so56635fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:47:01 -0800 (PST)
In-Reply-To: <1292259931.2759.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 1:05 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
>
> Hmm, this wont work with CPU HOTPLUG.
>
> When we put a cpu offline, we can transfert tasklets from this cpu to
> another 'online cpu'
>
> To solve this, you need that ri_tasklet() not use a "device pointer"
> parameter but a pointer to 'cpu' private data, since it can be differ=
ent
> than the data of the current cpu.
>
> static void ri_tasklet(unsigned long arg)
> {
> struct ifb_q_private *qp =3D (struct ifb_q_private *)arg;
>
> =A0 =A0 =A0 =A0...
> }
>

You are right, and it was my original way. Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
