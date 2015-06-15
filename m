From: punnaiah choudary kalluri <punnaia@xilinx.com>
Subject: Re: Support for Ethernet Phy interfaced through i2c bus
Date: Mon, 15 Jun 2015 17:17:22 +0530
Message-ID: <CAGnW=BYMCXAu8f6TgiXCPB11ufKrKdt5wH0VhUH1x8oYkvtZ9g@mail.gmail.com>
References: <CAGnW=BakaGvnZREG2qTT91dhvitHjpc-ts6b+xhh+OU_KPN-uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Punnaiah Choudary <kpc528@gmail.com>,
	punnaiah choudary kalluri <kalluripunnaiahchoudary@gmail.com>,
	appanad@xilinx.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36016 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbbFOLrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 07:47:23 -0400
Received: by pdjm12 with SMTP id m12so71275270pdj.3
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 04:47:23 -0700 (PDT)
In-Reply-To: <CAGnW=BakaGvnZREG2qTT91dhvitHjpc-ts6b+xhh+OU_KPN-uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any inputs on this ?

Regards,
Punnaiah

On Tue, May 26, 2015 at 9:23 PM, punnaiah choudary kalluri
<punnaia@xilinx.com> wrote:
> Hi,
>
> I have a design for adding the sgmii support to the Ethernet mac.
> The Ethernet mac is interfaced to the SGMII core and the mdio interface
> from the mac is connected to the sgmii core for querying the link status
> and autonegotaiation status.
> The external phy is connected to the i2c bus and it is accessed through
> i2c controller.
>
> I have tested this design with out registering phy framework and configured
> the external phy using the i2c lib and modified the Ethernet driver to include
> code for accessing the sgmii core using the mdio interface.
>
> Now i am looking for a solution to implement the following requirement using the
> existing phy framework. But it looks the current phy framework is using only
> the mdio bus.
>
> Could some one suggest the better approach or solution for
> implementing the below
> requirement.
>
>
>     --------
>    |        |   I2C
>    | I2c   |----------------
>    | ctrl|   |               |
>     ---------                |
>     ----------               |                                  -----------
>    |          |              -------------------------------- |           |
>    | MAC  |                                               |           |
>    |          |    MDIO     ------------     TX/RX   |   PHY |
>    |          |---------------- |            |---------------- |           |
>    |          | GMII         | SGMII |                 |           |
>    |          | --------------- |            |                  -----------
>     ----------                  |            |
>                                  ----------
> Regards,
> Punnaiah
