From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Fri, 20 Apr 2012 17:54:51 +0200
Message-ID: <CAKfDRXgd-9w_PL47OynVL3LX-Z7vG4skGOkQxOLc74=7jWBBXQ@mail.gmail.com>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
	<CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
	<20120419133635.7d816d67@nehalam.linuxnetplumber.net>
	<CAKfDRXih39RVnx1P72due=_v9-ORWf=YUfUTPKcvVbNzVuTLdw@mail.gmail.com>
	<20120420081400.67a98836@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52849 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757165Ab2DTPyw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 11:54:52 -0400
Received: by iagz16 with SMTP id z16so13558457iag.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 08:54:51 -0700 (PDT)
In-Reply-To: <20120420081400.67a98836@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 20, 2012 at 5:14 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>
> Check if ip command catches the events (ip monitor).

ip monitor catches the event, also when I run ip monitor link. I.e.,
the message is sent to the RTMGRP_LINK, which the application
subscribes to.

> What is the type of device? and what do you =A0mean by connecting?
> (ie installing, doing admin up, operstate transition, carrier)

The devices are USB 3G Modems (Huawei e173). By connecting, I mean
when ppp has established a successful connection. I.e., the device is
seen as IFF_RUNNING/IF_OPER_UP.

-Kristian
