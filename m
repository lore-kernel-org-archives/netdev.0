From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/9] [TULIP] Fix PHY init and reset
Date: Wed, 09 Aug 2006 01:29:33 -0400
Message-ID: <44D972BD.6020108@garzik.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca> <11549840122892-git-send-email-kyle@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	val_henson@linux.intel.com, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52127 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030475AbWHIF3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:29:36 -0400
To: Kyle McMartin <kyle@parisc-linux.org>
In-Reply-To: <11549840122892-git-send-email-kyle@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kyle McMartin wrote:
> From: Grant Grundler <grundler@parisc-linux.org>
> 
> A whole slew of fixes for tulip_select_media for:
>  - Flush posted MMIO writes as per PCI spec
>  - Polling the reset bit (bit 15) is required to determine when
>    the "init" sequence can be sent.
> 
> This fixes tulip on HP PA-RISC systems, which use DP83840A and
> LXT971D PHYs. Tested for several years on a variety of HP PA-RISC
> systems.
> 
> [Initial work done by Grant Grundler, DS21142 support added by
> Thibaut Varene.]
> 
> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> Signed-off-by: Thibaut Varene <varenet@parisc-linux.org>
> Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>

seems OK except for two details:

* [old news]  the delays should turn into sleeps, once Francois's patch 
is applied
* seems like you should be using get_u16() etc. for possibly-unaligned data


