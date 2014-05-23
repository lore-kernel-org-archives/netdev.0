From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/3] mdio: Parse DT nodes for auto-probed PHYs
Date: Fri, 23 May 2014 12:24:47 -0700
Message-ID: <CAGVrzcZJ400StBKikE32BiZq7_oZos7eHyCDCDXVmqisQMa8Tw@mail.gmail.com>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
 <5371A086.4040402@gmail.com> <537E3F87.4090803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	mugunthanvnm <mugunthanvnm@ti.com>,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:51428 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaEWTZ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 15:25:28 -0400
Received: by mail-qc0-f180.google.com with SMTP id i17so8949866qcy.11
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 12:25:28 -0700 (PDT)
In-Reply-To: <537E3F87.4090803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

2014-05-22 11:18 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> Hi Florian,
>
> On 05/13/2014 06:33 AM, Florian Fainelli wrote:
>> Le 10/05/2014 09:37, Daniel Mack a =C3=A9crit :
>>> Hi Florian,
>>>
>>> here's another aproach of solving the issue with auto-probed buses =
and
>>> DT device nodes. In short, this patch set introduces a new hook whi=
ch
>>> sets the of_node pointer of a phy device to a subnode of the bus, i=
f
>>> there is any which matches the phy's address. This function is call=
ed
>>> from mdiobus_scan(), and is a no-op for !CONFIG_OF.
>>>
>>> Unlike with with the 1st version, dev->of_node is now available in =
the
>>> PHY driver's probe() callback already.
>>>
>>> Let me know what you think, I'm open to other ideas :)
>>
>> I like it so far, I will give this a try on some of my quirky hardwa=
re.
>> Thanks!
>
> Did you have a chance yet to test these patches? I can submit a v2 wh=
ich
> does the requested of_property_read_u32() change.

I just tested those patches, and they look good. Please resubmit a v2
with the of_property_read_u32() changes and feel free to add my:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

tag, thanks!
--=20
=46lorian
