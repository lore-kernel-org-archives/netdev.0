From: Bernhard Walle <bernhard@bwalle.de>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Wed, 2 Mar 2016 21:05:40 +0100
Message-ID: <20160302200540.GA10722@euler.fritz.box>
References: <56D5CE66.3010602@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay05.ispgateway.de ([80.67.31.97]:53731 "EHLO
	smtprelay05.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbcCBUFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:05:46 -0500
Content-Disposition: inline
In-Reply-To: <56D5CE66.3010602@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

sorry for my late reply.

* Troy Kisky <troy.kisky@boundarydevices.com> [2016-03-01 18:16]:
>    invalid and 1 millisecond will be used instead.
> +- phy-reset-active-low : If present then the reset sequence using the GPIO
> +  specified in the "phy-reset-gpios" property is reversed (H=reset state,
> +  L=operation state).
> ____________________________
> 
> 
> Shouldn't this be named phy-reset-active-high, as you are making the reset active high
> H=reset, L= normal operation

Indeed, you're correct.

Should I send a new patch or a patch that corrects my first patch?
Because it already is in linux-next.

Regards,
Bernhard
