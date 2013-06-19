From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Wed, 19 Jun 2013 16:36:34 +0100
Message-ID: <1371656194.1956.25.camel@bwh-desktop.uk.level5networks.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
	 <51BF59D8.10806@gmail.com>
	 <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <john.fastabend@gmail.com>, <netdev@vger.kernel.org>,
	<john.r.fastabend@intel.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38615 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641Ab3FSPgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:36:39 -0400
In-Reply-To: <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 07:29 -0700, Narendra_K@Dell.com wrote:
[...]
> 2. show_phys_port  function sees a consistent value of
> 'netdev->phys_port.port_id and netdev->phys_port.port_id_len '  if
> another execution path changes the value of 'netdev->phys_port.port_id
> and netdev->phys_port.port_id_len '  with write_lock(&dev_base_lock)
> held (similar to how dev->operstate is being changed).
[...]

If the physical port ID can change dynamically (I hadn't thought of
that, but an embedded switch could support such reconfiguration) then
any such change also needs to be announced through rtnetlink.  Actually,
I think the value needs to be included in rtnetlink information anyway.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
