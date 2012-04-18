From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dmfe: enforce consistent timing delay.
Date: Tue, 17 Apr 2012 22:59:24 -0400 (EDT)
Message-ID: <20120417.225924.1599146568561338219.davem@davemloft.net>
References: <20120417211140.GA12909@electric-eye.fr.zoreil.com>
	<CANEJEGsb6_6btnu4OdriK=V2MbHcmxmvGy8UgsjNG1VPS_B0oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: grantgrundler@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab2DRDA3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 23:00:29 -0400
In-Reply-To: <CANEJEGsb6_6btnu4OdriK=V2MbHcmxmvGy8UgsjNG1VPS_B0oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Grant Grundler <grantgrundler@gmail.com>
Date: Tue, 17 Apr 2012 14:45:38 -0700

> On Tue, Apr 17, 2012 at 2:11 PM, Francois Romieu <romieu@fr.zoreil.co=
m> wrote:
>> The driver does not always use the same timing for what looks like
>> the same operations.
>>
>> - DCR0
>> =A0Use the same udelay everywhere for reset. Upper bound is 100 us.
>> - DCR9
>> =A0Use 5us delay for srom clock. 1us delay for phy_write_1bit (write=
s
>> =A0PHY_DATA_[01]) are not changed as they stay withing a 2,5MHz MDIO
>> =A0clock range.
>>
>> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>=20
>=20
> Reviewed-by: Grant Grundler <grundler@parisc-linux.org>

Applied, thanks.
