From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [BUG] tg3: frequent freezes
Date: Mon, 16 Jul 2012 23:56:29 -0700
Message-ID: <1342508189.2168.14.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1342503329.2626.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1853 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750812Ab2GQG4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 02:56:35 -0400
In-Reply-To: <1342503329.2626.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 07:35 +0200, Eric Dumazet wrote:
> [  266.248330] tg3 0000:09:00.0: eth0: 0x00004800: 0x080303fe,
> 0x00000010, 0x00000000, 0x00000020

RDMAC_STATUS (0x4804) is showing 0x10 which is parity error.

>[  266.247878] tg3 0000:09:00.0: eth0: 0x00000000: 0x167314e4,
>0x40100506, 0x02000002, 0x00000010

PCI Status (0x06) is also showing SERR (0x4000)

Assuming your chip is not a bad chip, I'll have to look around for a
5755M and see if I can duplicate the problem.
