From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: correct sysfs 'device' link creation and parent
 relationships
Date: Wed, 08 Dec 2010 10:11:21 -0800 (PST)
Message-ID: <20101208.101121.71114237.davem@davemloft.net>
References: <1291587480.17538.12.camel@dcbw.foobar.com>
	<AANLkTikhkVPcibAH8cSRvZSLop=Ew19Tn=KtY7prkKUn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dcbw@redhat.com, netdev@vger.kernel.org, duncan.sands@free.fr,
	linux-usb@vger.kernel.org, chas@cmf.nrl.navy.mil
To: kay.sievers@vrfy.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58525
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755801Ab0LHSKy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 13:10:54 -0500
In-Reply-To: <AANLkTikhkVPcibAH8cSRvZSLop=Ew19Tn=KtY7prkKUn@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kay Sievers <kay.sievers@vrfy.org>
Date: Tue, 7 Dec 2010 08:35:53 +0100

> On Sun, Dec 5, 2010 at 23:17, Dan Williams <dcbw@redhat.com> wrote:
>> The ATM subsystem was incorrectly creating the 'device' link for ATM
>> nodes in sysfs. =A0This led to incorrect device/parent relationships
>> exposed by sysfs and udev. =A0Instead of rolling the 'device' link b=
y hand
>> in the generic ATM code, pass each ATM driver's bus device down to t=
he
>> sysfs code and let sysfs do this stuff correctly.
>=20
> Looks good to me.

I've applied this to net-2.6, thanks Dan.
