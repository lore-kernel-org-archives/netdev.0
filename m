From: =?UTF-8?B?QWxleCBWaWxsYWPDrXMgTGFzc28=?= <a_villacis@palosanto.com>
Subject: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on cable plug on
 Acer Aspire One, no network
Date: Sun, 01 Jul 2012 08:50:15 -0500
Message-ID: <4FF05597.3040206@palosanto.com>
References: <4FD4F28B.4070003@palosanto.com> <20120610195906.GA15641@electric-eye.fr.zoreil.com> <4FD504DA.3000500@palosanto.com> <20120611213815.GA8517@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:41689 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331Ab2GANuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 09:50:19 -0400
In-Reply-To: <20120611213815.GA8517@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 11/06/12 16:38, Francois Romieu escribi=C3=B3:
> Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
> [...]
>> $ grep XID dmesg-3.5.0-rc2.txt
>> [   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e000,
>> 00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44
> The 8102e has not been touched by that many suspect patches but I do
> not see where the problem is :o(
>
> Can you peel off the r8169 patches between 3.4.0 and 3.5-rc ?
>
Still present in 3.5-rc5. Bisection still in progress.
