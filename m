From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Thu, 22 May 2014 20:18:47 +0200
Message-ID: <537E3F87.4090803@gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com> <5371A086.4040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, mugunthanvnm@ti.com,
	ujhelyi.m@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:42752 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbaEVSSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 14:18:55 -0400
Received: by mail-wi0-f171.google.com with SMTP id cc10so7079886wib.16
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 11:18:54 -0700 (PDT)
In-Reply-To: <5371A086.4040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On 05/13/2014 06:33 AM, Florian Fainelli wrote:
> Le 10/05/2014 09:37, Daniel Mack a =C3=A9crit :
>> Hi Florian,
>>
>> here's another aproach of solving the issue with auto-probed buses a=
nd
>> DT device nodes. In short, this patch set introduces a new hook whic=
h
>> sets the of_node pointer of a phy device to a subnode of the bus, if
>> there is any which matches the phy's address. This function is calle=
d
>> from mdiobus_scan(), and is a no-op for !CONFIG_OF.
>>
>> Unlike with with the 1st version, dev->of_node is now available in t=
he
>> PHY driver's probe() callback already.
>>
>> Let me know what you think, I'm open to other ideas :)
>=20
> I like it so far, I will give this a try on some of my quirky hardwar=
e.=20
> Thanks!

Did you have a chance yet to test these patches? I can submit a v2 whic=
h
does the requested of_property_read_u32() change.


Thanks and best regards,
Daniel
