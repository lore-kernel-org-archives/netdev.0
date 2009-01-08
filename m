From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 03:14:06 +0000
Message-ID: <1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>
References: <200901080203.SAA19103@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3066 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752147AbZAHDJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 22:09:14 -0500
In-Reply-To: <200901080203.SAA19103@tardy.cup.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-07 at 18:03 -0800, Rick Jones wrote:
> Certain Broadcom 10Gb Ethernet solutions (e.g. the 57711E) can have a
> 10Gb port split into multiple virtual NICs each with an instance of
> the bnx2x driver.  These virtual NICs can be configured for any speed
> which is an integer multiple of 100 Mb/s from 100 to 10,000 Mbit/s
> inclusive.  Since this is "normal" for such systems an "Unknown!" is
> not indicated.
[...]

The vetting of speeds is kind of silly.  Given that speed is established
as being a number of Mbit/s (hence the need for speed_hi), why not
remove the warning and the checks for known values and report it as
such?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

