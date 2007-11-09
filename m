From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] using mii-bitbang on different processor ports	-	update
 the booting-without-of.txt-file
Date: Fri, 09 Nov 2007 10:03:23 -0600
Message-ID: <473484CB.1010604@freescale.com>
References: <1194339117.3467.8.camel@p60635-ste.ids.de>	 <20071106184649.GA5283@loki.buserror.net>	 <1194442844.3571.14.camel@p60635-ste.ids.de>	 <47336F9D.8060405@freescale.com> <1194608283.8755.10.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
To: Sergej Stepanov <Sergej.Stepanov@ids.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57909 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbXKIQEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 11:04:06 -0500
In-Reply-To: <1194608283.8755.10.camel@p60635-ste.ids.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergej Stepanov wrote:
>> We also need to change the reference to port C in fsl,mdio-pin and 
>> fsl,mdc-pin.
> Do you mean this:
>    Currently defined compatibles:
>    fsl,pq1-fec-mdio (reg is same as first resource of FEC device)
> -> fsl,cpm2-mdio-bitbang (reg is port C registers)
> 
>    Properties for fsl,cpm2-mdio-bitbang:
> -> fsl,mdio-pin : pin of port C controlling mdio data
> -> fsl,mdc-pin : pin of port C controlling mdio clock

Yes.

> Right. But i thought it would be related to the example,
> and than the reader gets the short comment about I/O ports.

No, the example is the example, and the spec is the spec. :-)

> Or the other variant would be:
> --------------------
>    iv) MDIO
> 
>    Currently defined compatibles:
>    fsl,pq1-fec-mdio (reg is same as first resource of FEC device)
>    fsl,cpm2-mdio-bitbang (reg is the I/O port register block(s))
> 
>    Properties for fsl,cpm2-mdio-bitbang:
>    The first reg resource is the I/O port register block on which MDIO
>    resides.  The second reg resource is the I/O port register block on
>    which MDC resides.  If there is only one reg resource, it is used for
>    both MDIO and MDC.
>    fsl,mdio-pin : pin of chosen port for controlling mdio data
>    fsl,mdc-pin : pin of chosen port for controlling mdio clock

Looks good.  We can eliminate the parenthetical for 
fsl,cpm2-mdio-bitbang because reg is now explained below.

-Scott
