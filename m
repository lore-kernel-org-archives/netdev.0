From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH] Initialize dev_id sysfs attribute to -1 by default
Date: Mon, 10 Jun 2013 11:43:04 -0700
Message-ID: <51B61E38.6000908@intel.com>
References: <20130530132419.GA1368@fedora-17-guest.blr.amer.dell.com>  <87fvx4mvtl.fsf@nemi.mork.no>  <20130531121737.GB1311@fedora-17-guest.blr.amer.dell.com>  <51B1F1FF.5010004@intel.com> <1370618634.1903.3.camel@bwh-desktop.uk.level5networks.com> <51B2152E.5010105@gmail.com> <E31FB011129F30488D5861F383904915210BA89DFD@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, bhutchings@solarflare.com, bjorn@mork.no,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32434 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297Ab3FJSnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 14:43:05 -0400
In-Reply-To: <E31FB011129F30488D5861F383904915210BA89DFD@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> Hi John, thank you for the inputs.  It was set to  -1 to differentiate between driver setting it to zero and the default value zero.
>

The point I was trying to make here is setting it to a single
digit 0, 1, or -1 doesn't really help in a virtualized environment
where you may not have access to the PCI topology, serial #s, etc.
You need a system-wide unique id.

Anyways looks like your on the right track.

.John
