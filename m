From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on cable plug on Acer Aspire One, no network
Date: Mon, 11 Jun 2012 23:38:15 +0200
Message-ID: <20120611213815.GA8517@electric-eye.fr.zoreil.com>
References: <4FD4F28B.4070003@palosanto.com> <20120610195906.GA15641@electric-eye.fr.zoreil.com> <4FD504DA.3000500@palosanto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Alex =?utf-8?B?VmlsbGFjw61z?= Lasso <a_villacis@palosanto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53439 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2FKVrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 17:47:42 -0400
Content-Disposition: inline
In-Reply-To: <4FD504DA.3000500@palosanto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Villac=C3=ADs Lasso <a_villacis@palosanto.com> :
[...]
> $ grep XID dmesg-3.5.0-rc2.txt
> [   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e000,
> 00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44

The 8102e has not been touched by that many suspect patches but I do
not see where the problem is :o(

Can you peel off the r8169 patches between 3.4.0 and 3.5-rc ?

--=20
Ueimor
