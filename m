From: Stefan Roese <sr@denx.de>
Subject: Re: e1000e "Detected Tx Unit Hang"
Date: Mon, 14 Jul 2008 09:47:46 +0200
Message-ID: <200807140947.46733.sr@denx.de>
References: <4866211E.6040704@embedded-sol.com> <36D9DB17C6DE9E40B059440DB8D95F5205953CF7@orsmsx418.amr.corp.intel.com> <487AFE97.8090107@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org
To: Felix Radensky <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:50385 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754643AbYGNHsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 03:48:14 -0400
In-Reply-To: <487AFE97.8090107@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix,

On Monday 14 July 2008, Felix Radensky wrote:
> I'm CC-ing Stefan, who ported Linux to this platform.
>
> Applying the patch you suggested did not help. I'm still getting TX unit
> hangs. I don't see any netdev watchdog messages. When the hang occurs
> I cannot get the prompt, so I cannot run ethtool.
>
> The following command works always
>
> dd if=/dev/zero of=/mnt/test bs=512 count=2
>
> and the following causes Tx unit hang
>
>  dd if=/dev/zero of=/mnt/test bs=512 count=3
>
> Stefan, are you aware of any PCIe related problems on Canyonlands ?
> AMCC have compatibility chart on their site, which indicates that this
> particular card (Intel PRO/1000 T Desktop Adapter) Iwas tested with
> linux-2.6.25 kernel.

What Linux kernel version did you use? From kernel.org or from the 
linux-2.6-denx repository? Please send the complete bootup log including 
U-Boot startup log.

Thanks.

Best regards,
Stefan
