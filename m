From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [V2] net: emaclite: adding MDIO and phy lib support
Date: Tue, 9 Feb 2010 08:45:15 -0700
Message-ID: <fa686aa41002090745x19d569acx3b50e8078ebb16f7@mail.gmail.com>
References: <1265409646-11882-1-git-send-email-john.linn@xilinx.com>
	<260b8801-53bd-44fe-a6b8-7d1d0f56fef5@SG2EHSMHS011.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	jwboyer@linux.vnet.ibm.com, john.williams@petalogix.com,
	Sadanand Mutyala <sadanan@xilinx.com>
To: John Linn <John.Linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:32917 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754411Ab0BIPpg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 10:45:36 -0500
Received: by iwn1 with SMTP id 1so3516901iwn.24
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 07:45:35 -0800 (PST)
In-Reply-To: <260b8801-53bd-44fe-a6b8-7d1d0f56fef5@SG2EHSMHS011.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 8, 2010 at 7:09 AM, John Linn <John.Linn@xilinx.com> wrote:
>> -----Original Message-----
>> From: John Linn [mailto:john.linn@xilinx.com]
>> Sent: Friday, February 05, 2010 3:41 PM
>> To: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org;
> jgarzik@pobox.com; grant.likely@secretlab.ca;
>> jwboyer@linux.vnet.ibm.com
>> Cc: john.williams@petalogix.com; John Linn; Sadanand Mutyala
>> Subject: [PATCH] [V2] net: emaclite: adding MDIO and phy lib support
>>
>> These changes add MDIO and phy lib support to the driver as the
>> IP core now supports the MDIO bus.
>>
>> The MDIO bus and phy are added as a child to the emaclite in the
> device
>> tree as illustrated below.
>>
>> mdio {
>> =A0 =A0 =A0 #address-cells =3D <1>;
>> =A0 =A0 =A0 #size-cells =3D <0>;
>> =A0 =A0 =A0 compatible =3D "xlnx,emaclite-mdio";
>> =A0 =A0 =A0 phy0: phy@7 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D <7>;
>> =A0 =A0 =A0 } ;
>> }

You misunderstood me about the compatible property.  You don't need a
compatible prop in the mdio node because it is *alwasy* a child of the
emaclite node, and the emaclite driver knows to go looking for it (ie.
it is a part of the device).

What I want to see is a compatible value in the phy@7 node for the
make & model of the phy.

Otherwise, looks good to me.  Fix the mutex timeout problem and then
you can add my acked-by line to the patch.

Cheers,
g.
