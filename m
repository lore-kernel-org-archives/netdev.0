From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: rtl8168e-vl dropping tftp ack
Date: Wed, 17 Apr 2013 23:32:51 +0200
Message-ID: <20130417213251.GA13790@electric-eye.fr.zoreil.com>
References: <516EB23B.3080504@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Stefan Bader <stefan.bader@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53380 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965578Ab3DQVdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:33:00 -0400
Content-Disposition: inline
In-Reply-To: <516EB23B.3080504@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Bader <stefan.bader@canonical.com> :
[...]
> The Xen host has the Realtek NIC:
> 
> 2:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.
>        RTL8111/8168B PCI Express Gigabit Ethernet controller
>        [10ec:8168] (rev 06)
>        Subsystem: Micro-Star International Co., Ltd. Device [1462:7798]

Please include the XID line from the stock kernel.

[...]
> I am not sure this is enough to find out what goes wrong but I can
> add debugging code to the kernel driver or gather other info if
> someone can hint me which things would be of interest.

(tentative guess: small packet / checksumming problem)

A pcap capture file at the interface of the tftp server with Realtek's
driver (working) then with the kernel driver (failing) should help a
lot. No need to play the soft link trick but using a recent kernel will
be appreciated - fixes will be backported to stable kernels if needed.

-- 
Ueimor
