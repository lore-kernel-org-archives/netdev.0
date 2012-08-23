From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH v2] net: add new QCA alx ethernet driver
Date: Thu, 23 Aug 2012 15:28:55 +0500
Message-ID: <CAB=NE6V1yC-0pXPBXrObepJ7CkBPeynHZ3YJYf0ZGpqrCUPBUA@mail.gmail.com>
References: <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
 <20120822.234019.1546353507351890178.davem@davemloft.net> <157393863283F442885425D2C45428562A4F519A@nasanexd02f.na.qualcomm.com>
 <20120823.001342.959509094678320374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: xiong@qca.qualcomm.com, cjren@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	Adrian Chadd <adrian@freebsd.org>,
	Vinod Nagarajan <Vinod.Nagarajan@qca.qualcomm.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Lisong Guo <livesogood@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42081 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972Ab2HWK3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 06:29:16 -0400
In-Reply-To: <20120823.001342.959509094678320374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 11:13 AM, David Miller <davem@davemloft.net> wrote:
> From: "Huang, Xiong" <xiong@qca.qualcomm.com>
> Date: Thu, 23 Aug 2012 06:56:51 +0000
>
>> I'm afraid someone also rejects my request to add such operation to
>> ethtool
>
> If you don't design it properly, we certainly will ask you to make
> changes.
>
> But it stands a chance of actually being accepted, whereas your
> debugfs thing absolutely does not.

Xiong, you can dump that poo and put it into crap/ in compat-drivers
until you find a resolution to properly address that properly.

FWIW... if we give a rats ass on trying to put an end typical internal
proprietary development trees to port drivers to different OSes [0]
here's a cheesy attempt to try address this with a target for Linux
and FreeBSD as a first objective:

https://github.com/mcgrof/alx

The goal would be to push companies to do their bringup development
*openly* and even if they do have support for other OSes, for that poo
to also be public. The alx driver is a dead simple so my if at all
possible to show a *different* community-lead way to port drivers and
for this poo to be public my hope is that the alx driver can be the
test case for us to try it on.

Xiong, and whoever cares please think about it. I welcome feedback from others.

[0] http://www.youtube.com/watch?v=9P-r3H0bY8c

  Luis
