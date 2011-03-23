From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Wed, 23 Mar 2011 12:45:26 -0700 (PDT)
Message-ID: <20110323.124526.02255431.davem@davemloft.net>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
	<4D8A4931.10903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net,
	fubar@us.ibm.com
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58865
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932366Ab1CWTor convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 15:44:47 -0400
In-Reply-To: <4D8A4931.10903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Wed, 23 Mar 2011 20:25:37 +0100

> Le 22/03/2011 13:38, Jiri Pirko a =E9crit :
>> This prevents possible race between bond_enslave and bond_handle_fra=
me
>> as reported by Nicolas by moving rx_handler register/unregister.
>> slave->bond is added to hold pointer to master bonding sructure. Tha=
t
>> way dev->master is no longer used in bond_handler_frame.
>> Also, this removes "BUG: scheduling while atomic" message
>>
>> Reported-by: Nicolas de Peslo=FCan<nicolas.2p.debian@gmail.com>
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>=20
> Thanks Jiri, it works.
>=20
> Tested-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied, thanks everyone.
