From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: RE: [PATCH] ibm_newemac: Add support for GPCS, SGMII and
	M88E1112PHY
Date: Tue, 09 Sep 2008 17:12:40 +1000
Message-ID: <1220944360.4879.326.camel@pasglop>
References: <1220658734-13944-1-git-send-email-vgallardo@amcc.com>
	 <1220833754.4879.228.camel@pasglop>
	 <0CA0A16855646F4FA96D25A158E299D602C8135D@SDCEXCHANGE01.ad.amcc.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Feng Kan <fkan@amcc.com>,
	netdev@vger.kernel.org
To: Victor Gallardo <vgallardo@amcc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57109 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755431AbYIIHMy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 03:12:54 -0400
In-Reply-To: <0CA0A16855646F4FA96D25A158E299D602C8135D@SDCEXCHANGE01.ad.amcc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-09-07 at 22:57 -0700, Victor Gallardo wrote:
> Hello Benjamin,
>  
> On the 460EX/GT in SGMII mode, GPCS access is needed for communication with the internal SGMII SerDes. It is possible that there is still a PHY. So we need a way to access both addresses.
>  
> For Example on the AMCC Arches Board.
>  
> EMAC 0 has only a GPCS PHY (address 0xA)
> EMAC 1 has M88E1112 PHY (address 0x0) and GPCS PHY (address 0xB)
> EMAC 2 has M88E1112 PHY (address 0x1) and GPCS PHY (address 0xC)

Ok. Thanks. I need to review your patch a bit better, hopefully later
this week. I'll let you know. Ping me if you get no news by next monday.

Cheers,
Ben.

> Regards,
>  
> Victor Gallardo
> 
> ________________________________
> 
> From: Benjamin Herrenschmidt [mailto:benh@kernel.crashing.org]
> Sent: Sun 9/7/2008 5:29 PM
> To: Victor Gallardo
> Cc: linuxppc-dev@ozlabs.org; Feng Kan
> Subject: Re: [PATCH] ibm_newemac: Add support for GPCS, SGMII and M88E1112PHY
> 
> 
> 
> On Fri, 2008-09-05 at 16:52 -0700, Victor Gallardo wrote:
> > From: Victor Gallardo <vgallardo@amcc.com>
> >
> > This patch adds GPCS, SGMII and M88E1112 PHY support
> > for the AMCC PPC460GT/EX processors.
> 
> So if I understand the patch correctly, either there is an *MII PHY in
> which case phy_address is used, or there's a GPCS one and phy_address is
> -1 and gpcs_address is used right ?
> 
> Why not instead always use phy_address, and have a flag indicating
> whether it's an MII or GPCS PHY ? This would avoid the added
> gpcs_read/write functions, among other things, and I believe would look
> cleaner... Or am I missing something ?
> 
> Cheers,
> Ben.
> 
> 
> 
> 

