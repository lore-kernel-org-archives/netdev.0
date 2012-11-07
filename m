From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Lower wake up time when phy enter lower mode
Date: Wed, 7 Nov 2012 19:06:23 +0000
Message-ID: <1352315183.2725.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAHrpEqSw8N4nN6Wgnu2z3tWS_CrGoPMbFj2wJjmDv2JPLW7cLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60342 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754106Ab2KGTG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 14:06:26 -0500
In-Reply-To: <CAHrpEqSw8N4nN6Wgnu2z3tWS_CrGoPMbFj2wJjmDv2JPLW7cLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-07 at 10:52 +0800, Frank Li wrote:
> Richard:
> 
>           Recently, I found out the path delay will increase about
> 20us suddenly in something when connect two iMX6 board and Ethernet
> work on 1G mode.
>           The reason is that the PHY enter lower mode automatically
> when no package send and receive. It takes some time to recover and
> send out package by PHY but MAC think package have sent and sample
> time stamper.
>           Do you meet such case?  I can workaround it by two method
>                1. disable phy lower power feature.
>                2. add some dummy package before SYNC package.

If this low power mode is related to EEE (Energy Efficient Ethernet)
then there are ethtool operations defined for configuring it, and you
could implement those.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
