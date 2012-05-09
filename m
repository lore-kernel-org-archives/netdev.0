From: =?ISO-8859-1?Q?Alex_Villac=EDs_Lasso?= <a_villacis@palosanto.com>
Subject: Re: [PATCH] r8169: fix problem with TSO (TX_BUFFS_AVAIL negative
 value)
Date: Tue, 08 May 2012 23:12:28 -0500
Message-ID: <4FA9EEAC.7010201@palosanto.com>
References: <1336430367.11363.38.camel@blackbone.local> <20120507234205.GA2230@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Pilarski <thomas.pi@arcor.de>,
	Julien Ducourthial <jducourt@free.fr>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([200.93.199.101]:43695 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab2EIEMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 00:12:50 -0400
In-Reply-To: <20120507234205.GA2230@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 07/05/12 18:42, Francois Romieu escribi=F3:
> Julien Ducourthial<jducourt@free.fr>  :
>> The r8169 may get stuck or show bad behaviour after activating TSO :
>> the net_device is not stopped when it has no more TX descriptors.
>> This problem comes from TX_BUFS_AVAIL which may reach -1 when all
>> transmit descriptors are in use. The patch simply tries to keep posi=
tive
>> values.
> It seems more than good.
>
> Alex, Thomas, can you check if Julien's patch below fixes your broken
> kernels as well ?
>
No luck. The backtrace still appears after using the patched driver.
