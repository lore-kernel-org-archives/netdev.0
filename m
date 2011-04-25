From: =?big5?B?UmF0YmVydCBQby1ZdSBDaHVhbmcosviz1aZ0KQ==?=
	<ratbert@faraday-tech.com>
Subject: RE: linux-next ftmac100 driver
Date: Mon, 25 Apr 2011 11:26:13 +0800
Message-ID: <D557AF68929979498EDCFCBB34FFD4E82C62BC@ftcpcs78.faraday.com.tw>
References: <BANLkTin24N2D_b_RpPCQdjYn2f=C7NY2JA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="big5"
Content-Transfer-Encoding: 8BIT
Cc: <ratbert.chuang@gmail.com>, <netdev@vger.kernel.org>
To: "Adam Jaremko" <adam.jaremko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftcsun4.faraday-tech.com ([60.248.181.187]:64846 "EHLO
	ftcsun4.faraday.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758055Ab1DYDqD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 23:46:03 -0400
Received: from ftcpcs100.faraday.com.tw ([192.168.31.10])
	by ftcsun4.faraday.com.tw (8.11.7p1+Sun/8.11.6) with ESMTP id p3P3LtU00089
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 11:21:55 +0800 (CST)
Content-class: urn:content-classes:message
In-Reply-To: <BANLkTin24N2D_b_RpPCQdjYn2f=C7NY2JA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Adam,

CC to the netdev mainling list.

From: Adam Jaremko [mailto:adam.jaremko@gmail.com] 
> Hello,
> 
> I want to first thank you for the upstream contributions as they greatly helped me in my porting effort.
> 
> I have been testing your ftmac100 driver on a Moxa UC-7112 and have been struggling with a kernel BUG "scheduling while atomic".
>
> I narrowed down the bug to the napi polling routine ftmac100_poll(...) when a physical change occurs, ie. RJ-45 cable removed.
> @ http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=blob;f=drivers/net/ftmac100.c;h=a31661948c420e0d467c7e8b7bb4ecae4c078de0;hb=HEAD#l932
>
> the call to mii_check_link(...) calls ftmac100_mdio_read(...) which may incur a call to usleep_range(...) causing the bug.
> @ http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=blob;f=drivers/net/ftmac100.c;h=a31661948c420e0d467c7e8b7bb4ecae4c078de0;hb=HEAD#l757
> I haven't got a fix but I wanted to inform as you may have more insight.

You can try to use udelay() to replace usleep_range(). I will also check this problem when I am free later.
If you solved this problem before me, please send a message (and keep the CC list).
It will be even better if you could submit a patch. :-)

Thanks,
Po-Yu Chuang

********************* Confidentiality Notice ************************
This electronic message and any attachments may contain
confidential and legally privileged information or
information which is otherwise protected from disclosure.
If you are not the intended recipient,please do not disclose
the contents, either in whole or in part, to anyone,and
immediately delete the message and any attachments from
your computer system and destroy all hard copies.
Thank you for your cooperation.
***********************************************************************

