From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Thu, 1 May 2014 12:32:08 -0700
Message-ID: <1398972728.3056.49.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <5361C29C.5060808@taghos.com.br>
	 <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <53627814.7090106@taghos.com.br>
	 <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <53629752.6030606@taghos.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"desenvolvimento@taghos.com.br" <desenvolvimento@taghos.com.br>
To: "Magnos A. Hammes" <magnos@taghos.com.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:29312 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaEATcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 15:32:16 -0400
In-Reply-To: <53629752.6030606@taghos.com.br>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 15:49 -0300, Magnos A. Hammes wrote:
> Yes, I have some udev rules that run at system boot, but the only
> thing 
> I do is:
> 
> /sbin/udevd --daemon
> /sbin/udevadm trigger --type=subsystems --action=add
> /sbin/udevadm trigger --type=devices --action=add
> /sbin/udevadm settle
> 
> Udev runs normally and returns no errors or warnings and dmesg shows 
> nothing weird.
> 
> So, you think this may be a problem with my udev rules or a udev bug?
> 
> I'm using udev version 182.

udev is involved in locating and loading the firmware file.  On my
system, I have /lib/udev/firmware.sh and a
generic /lib/udev/rules.d/50-firmware.rules to make request_firmware()
work.  Your system may be different.
> 
> 
