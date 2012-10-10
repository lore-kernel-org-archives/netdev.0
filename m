From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: setting flow spec rules under vswitch configuration
Date: Wed, 10 Oct 2012 18:27:25 +0100
Message-ID: <1349890045.2691.0.camel@bwh-desktop.uk.solarflarecom.com>
References: <5073F073.3060403@mellanox.com>
	  <1349801311.2800.17.camel@bwh-desktop.uk.solarflarecom.com>
	  <50758353.6050309@mellanox.com>
	 <1349879306.6336.40.camel@deadeye.wl.decadent.org.uk>
	 <507586B9.6080505@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rony Efraim <ronye@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38170 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750948Ab2JJR1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 13:27:32 -0400
In-Reply-To: <507586B9.6080505@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 16:31 +0200, Or Gerlitz wrote:
> On 10/10/2012 16:28, Ben Hutchings wrote:
> > On Wed, 2012-10-10 at 16:16 +0200, Or Gerlitz wrote:
> > [...]
> >> >Thanks for setting the sketch of a plan here... so if we go little bit
> >> >into details, we can safely move 20 bytes from the hadata[60] field into
> >> >the beginning of struct ethtool_flow_ext, which will still allow old
> >> >user space to work with newer kernels. As for newer uses space that
> >> >would like to set mac addresses within
> >> >ethtool_flow_ext, how are they supposed to identify if the kernel
> >> >supports this extension (of the extension...)?
> > Well they can't tell in advance, but we can define another flag in
> > flow_type like FLOW_EXT and existing drivers will reject flow specs with
> > that flag set.
> I understand what we can add a flag which will be rejected by driver's 
> that don't support this ext,
> can the same/similar flag be used for newer user space code to mark they 
> want this ext?

Exactly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
