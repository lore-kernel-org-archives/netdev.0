From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
Subject: RE: [PATCH v2] Add support of Cavium Liquidio ethernet adapters
Date: Mon, 1 Dec 2014 19:57:20 +0000
Message-ID: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
References: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<54739C92.5070309@gmail.com>
 <20141124.160837.1008717214755094566.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Chickles, Derek" <Derek.Chickles@caviumnetworks.com>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>
To: David Miller <davem@davemloft.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:59234
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932101AbaLAT52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 14:57:28 -0500
In-Reply-To: <20141124.160837.1008717214755094566.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 24, 2014 1:09 PM
> To: f.fainelli@gmail.com
> Cc: Vatsavayi, Raghu; netdev@vger.kernel.org; Chickles, Derek; Burla,
> Satananda; Manlunas, Felix; Vatsavayi, Raghu
> Subject: Re: [PATCH v2] Add support of Cavium Liquidio ethernet adapters
> 
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon, 24 Nov 2014 13:01:06 -0800
> 
> > On 11/23/2014 07:19 PM, Raghu Vatsavayi wrote:
> >> +if LIQUIDIO
> >> +
> >> +config LIQUIDIO_NAPI
> >> +	bool "Enable NAPI for LiquidIO"
> >> +	default y
> >> +	---help---
> >> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
> >> +	  when the driver is receiving lots of packets from the card. You
> >> +	  would only disable this feature in very specific instances, like
> >> +	  an application that very rapidly sets up and tears down connections.
> >> +
> >> +	  If in doubt, say Y.
> >
> > You probably do not want to offer a non-NAPI variant, pretty much all
> > drivers have NAPI built-in now.
> 
> +1.
> 
> >> +config LIQUIDIO_DEBUG
> >> +	int "Debug level for LiquidIO"
> >> +	range 0 4
> >> +	default 0
> >
> > This should be moved to dynamic_debug/ethtools' msglvl control knob.
> 
> +1

Thanks for the comments. We are in the process of removing Kconfig based non-NAPI
selection and enabling NAPI by default. We are also removing  separate debug section
and integrating it with ethtool based msglvl debug infrastructure. Additionally we are
planning to clean up non-kerneldoc style comments.

Regards
Raghu
