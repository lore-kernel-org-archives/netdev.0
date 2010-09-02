From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: arp: code cleanup
Date: Thu, 2 Sep 2010 09:28:13 +0800
Message-ID: <AANLkTik1VFj_8G+G9bH+MvbUyNpSUmDfJUQF+-VCjeKu@mail.gmail.com>
References: <1283385110-2953-1-git-send-email-xiaosuo@gmail.com> <20100901.175712.199039832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46221 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab0IBB2g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 21:28:36 -0400
Received: by wyb35 with SMTP id 35so9956660wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 18:28:34 -0700 (PDT)
In-Reply-To: <20100901.175712.199039832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 2, 2010 at 8:57 AM, David Miller <davem@davemloft.net> wrot=
e:
>
> I do not condone comments being written this way, it wastes precious
> vertical space in one's terminal window. =A0They should always be
> written as:
>
> =A0 =A0 =A0 =A0/* A comment
> =A0 =A0 =A0 =A0 * looks like this.
> =A0 =A0 =A0 =A0 */

OK. Thanks.

>
>> @@ -258,31 +259,31 @@ static int arp_constructor(struct neighbour *n=
eigh)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 neigh->output =3D neigh->ops->queue_xmit=
;
>> =A0 =A0 =A0 } else {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Good devices (checked by reading text=
s, but only Ethernet is
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tested)
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ARPHRD_ETHER: (ethernet, apfddi)
> =A0...
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0in old paradigm.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* tested)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* ARPHRD_ETHER: (ethernet, apfddi)
>
> you go and apply COMPLETELY INCONSISTENT changes to other comemnts.
>
> Leave the comments alone, thanks.
>

Do you mean that all the multi-line comments should be written as you
said above or I should not touch any comment? Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
