From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: VLAN Question
Date: Sat, 29 Oct 2011 17:51:12 +0200
Message-ID: <4EAC20F0.9060508@gmail.com>
References: <CANgyXsS=cE_ONExEuOvL7NEme1xCTM5s2Eek+oM6SXu_0g_bAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roya Kachooei <rkachooei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41601 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932484Ab1J2Puu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 11:50:50 -0400
Received: by wwe6 with SMTP id 6so7121612wwe.1
        for <netdev@vger.kernel.org>; Sat, 29 Oct 2011 08:50:49 -0700 (PDT)
In-Reply-To: <CANgyXsS=cE_ONExEuOvL7NEme1xCTM5s2Eek+oM6SXu_0g_bAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 29/10/2011 15:35, Roya Kachooei a =E9crit :
> Hi there
>
>
> My question is that is it possible to bond or aggregate two virtual
> interfaces created by VLAN?
>
> In other words is it possible to bond two virtual links for improving
> fail over and load balance?

If both virtual links are supported by the same physical link, nothing =
will improve.

That being said, some people used VLAN to provide end-to-end links, acr=
oss one or several common=20
switches.

       +-eth0-----vlan-100-----eth0-+
       |                            |
bond0-+                            +-bond0
       |                            |
       +-eth1-----vlan-200-----eth1-+

	Nicolas.
