From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: etsec2 attached to sgmii phy
Date: Wed, 4 Oct 2017 15:36:42 +0200
Message-ID: <20171004133642.GM30045@lunn.ch>
References: <alpine.DEB.2.20.1710040756160.31757@brian.int1.clnt.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?J=F6rg?= Willmann <joe@clnt.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:39155 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752167AbdJDNgo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Oct 2017 09:36:44 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710040756160.31757@brian.int1.clnt.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 04, 2017 at 07:56:53AM +0200, Jörg Willmann wrote:
> Hi,
> 
> we use a QorIQ P1011 connected via SGMII to a switch (Marvell 88E6352).
> Currently we still use a really old linux kernel (2.6.33) successfully.
> 
> For configuration of the MDIO Bus attached to the corresponding eTSEC/TBI
> Phy we use the following settings in the device tree:
> 
>                         mdio@25000 {
>                                    #address-cells = <0x1>;
>                                    #size-cells = <0x0>;
>                                    compatible = "fsl,etsec2-tbi";
>                                    reg = <0x25000 0x1000 0xb1030 0x4>;

Hi Joerg

Is 0xb1030 0x4 fixed by the silicon? Can it be expressed as an offset from
0x25000?

It seems like the idea behind the patch is to hard code some
things. If you can hard code the offset into get_etsec_tbipa(), i
think that would be an O.K. solution to your problem.

      Andrew
