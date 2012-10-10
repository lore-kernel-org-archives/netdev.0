From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: setting flow spec rules under vswitch configuration
Date: Wed, 10 Oct 2012 15:28:26 +0100
Message-ID: <1349879306.6336.40.camel@deadeye.wl.decadent.org.uk>
References: <5073F073.3060403@mellanox.com>
	 <1349801311.2800.17.camel@bwh-desktop.uk.solarflarecom.com>
	 <50758353.6050309@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53059 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756464Ab2JJO2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 10:28:34 -0400
In-Reply-To: <50758353.6050309@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 16:16 +0200, Or Gerlitz wrote:
[...]
> Thanks for setting the sketch of a plan here... so if we go little bit 
> into details, we can safely move 20 bytes from the hadata[60] field into 
> the beginning of struct ethtool_flow_ext, which will still allow old
> user space to work with newer kernels. As for newer uses space that 
> would like to set mac addresses within
> ethtool_flow_ext, how are they supposed to identify if the kernel 
> supports this extension (of the extension...)?

Well they can't tell in advance, but we can define another flag in
flow_type like FLOW_EXT and existing drivers will reject flow specs with
that flag set.

> this might be newbee 
> question, I didn't made many ethtool patches so far.
> 
> Also on a related note, what does the 64bit data field of 
> ethtool_flow_ext used for?

Driver-dependent.  ixgbe uses it for something.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
