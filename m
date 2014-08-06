From: Nathan Lynch <Nathan_Lynch@mentor.com>
Subject: Re: [Regression] FEC: Panic on suspend in 3.16
Date: Wed, 6 Aug 2014 10:09:25 -0500
Message-ID: <53E24525.2020809@mentor.com>
References: <53E24147.4050304@parkeon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, <festevam@gmail.com>
To: Martin Fuzzey <mfuzzey@parkeon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:54351 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbaHFPJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:09:31 -0400
In-Reply-To: <53E24147.4050304@parkeon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2014 09:52 AM, Martin Fuzzey wrote:
> Hi all,
> 
> I am using the fec ethernet driver on a i.MX53 SoC.
> 
> All was working fine on 3.13 but, after upgrading to 3.16 I now get a
> panic on suspend:

Same issue reported here:

http://lists.infradead.org/pipermail/linux-arm-kernel/2014-August/277728.html

a71e3c37960c (net: phy: Set the driver when registering an MDIO bus
device) has been implicated; try reverting that.
