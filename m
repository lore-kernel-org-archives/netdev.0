From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net v3] veth: advertise peer link once both links are tied
 together
Date: Mon, 30 May 2016 18:27:10 +0200
Message-ID: <574C69DE.3050305@6wind.com>
References: <574C6095.9050804@6wind.com>
 <1464623917-11536-1-git-send-email-vincent@bernat.im>
 <87bn3n358j.fsf@zoro.exoscale.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34984 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933000AbcE3Q1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 12:27:14 -0400
Received: by mail-wm0-f45.google.com with SMTP id a136so93927245wme.0
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 09:27:13 -0700 (PDT)
In-Reply-To: <87bn3n358j.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2016 18:01, Vincent Bernat a =C3=A9crit :
>  =E2=9D=A6 30 mai 2016 17:58 CEST, Vincent Bernat <vincent@bernat.im>=
 :
>=20
>> +
>> +	rtmsg_ifinfo(RTM_NEWLINK, peer, IFF_SLAVE, GFP_KERNEL);
>=20
> Maybe ~0U would be better than hijacking IFF_SLAVE?
IFF_SLAVE is wrong. It's a flag here, that will be put in the ifi_chang=
e field
not an attribute number.
