From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Wed, 30 Apr 2014 22:39:28 -0700
Message-ID: <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <5361C29C.5060808@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Magnos A. Hammes" <magnos@taghos.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:57258 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbaEAFja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 01:39:30 -0400
In-Reply-To: <5361C29C.5060808@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 00:42 -0300, Magnos A. Hammes wrote:
> Hello,
> 
> 
> I have a Dell server with the following Broadcom gigabit network
> adapter that uses the bnx2 driver:
> 
>         01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II
>         BCM5716 Gigabit Ethernet (rev 20)
> 
> I was using kernel 3.2.57 and 3.13.3, but in both of them I faced some
> trouble to make the ethernet adapter work, whatever version of this
> two kernels that I try to boot I get the same error:
> 
>         Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
>         Direct firmware load failed with error -2
> 
We no longer put the firmware in the kernel tree, so you need to
download the firmware from the linux-firmware git tree:

git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
