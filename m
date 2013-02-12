From: Bhushan Bharat-R65777 <R65777@freescale.com>
Subject: RE: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 11:23:24 +0000
Message-ID: <6A3DF150A5B70D4F9B66A25E3F7C888D065A1614@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1360660088-27464-1-git-send-email-sr@denx.de>
 <6A3DF150A5B70D4F9B66A25E3F7C888D065A0271@039-SN2MPN1-023.039d.mgd.msft.net>
 <511A219A.7080000@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	Anatolij Gustschin <agust@denx.de>,
	"David S. Miller" <davem@davemloft.net>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:13221 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758815Ab3BLLX3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 06:23:29 -0500
In-Reply-To: <511A219A.7080000@denx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Stefan Roese [mailto:sr@denx.de]
> Sent: Tuesday, February 12, 2013 4:34 PM
> To: Bhushan Bharat-R65777
> Cc: netdev@vger.kernel.org; linuxppc-dev@ozlabs.org; Anatolij Gustschin; David
> S. Miller
> Subject: Re: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
> 
> On 12.02.2013 11:56, Bhushan Bharat-R65777 wrote:
> >> Until now, the MPC5200 FEC ethernet driver relied upon the bootloader
> >> (U-Boot) to write the MAC address into the ethernet controller
> >> registers. The Linux driver should not rely on such a thing. So lets
> >> read the MAC address from the DT as it should be done here.
> >>
> >> The following priority is now used to read the MAC address:
> >>
> >> 1) First, try OF node MAC address, if not present or invalid, then:
> >>
> >> 2) Read from MAC address registers, if invalid, then:
> >
> > Why we read from MAC registers if Linux should not rely on bootloader?
> 
> It was suggested by David. Backwards compatibility. Here Davids comment to my
> original patch which removed this register reading completely:
> 
> "
> I don't think this is a conservative enough change.
> 
> You have to keep the MAC register reading code around, as a backup code path in
> case the OF device node lacks a MAC address "

Ok,

But this is really a backward compatibility or hiding some bug? My thought is that if DT does not have a valid MAC address then it is a BUG and should be fixed. Is not it?

-Bharat

> 
> Thanks,
> Stefan
