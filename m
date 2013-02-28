From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH] bgmac: omit the fcs
Date: Thu, 28 Feb 2013 19:13:36 +0100
Message-ID: <512F9E50.1010907@hauke-m.de>
References: <1362071814-12822-1-git-send-email-hauke@hauke-m.de> <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:40608 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755251Ab3B1SNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 13:13:44 -0500
In-Reply-To: <CACna6rw6MR3agrDvz0+X7ne6uSNQN0tpZupeM5c-6xy5-pvv2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 06:57 PM, Rafa=C5=82 Mi=C5=82ecki wrote:
> 2013/2/28 Hauke Mehrtens <hauke@hauke-m.de>:
>> Do not include the frame check sequence when adding the skb to
>> netif_receive_skb(). This causes problems when this interface was
>> bridged to a wifi ap and a big package should be forwarded from this
>> Ethernet driver through a bride to the wifi client.
>=20
> Is this a real fix?
>=20
> Don't get me wrong, but it sounds a little like a workaround for some
> issue in another network layer ;)
>=20
Many drivers are doing similar things, b44 is one of them. Hopefully
someone more familiar with the network stack could say if this is the
right way to do this.

On a wireless client I saw that all packages directly from my router di=
d
not had a FCS, but all the packages send from an other LAN client which
went through this driver had a FCS and where 4 bytes bigger and this FC=
S
was wrong.

Hauke
