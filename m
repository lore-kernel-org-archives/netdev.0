From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ptp: dynamic allocation of PHC char devices
Date: Wed, 10 Apr 2013 18:37:16 +0100
Message-ID: <1365615436.2581.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <4a1dcbcfb28ea2d18b09561a370efe7a4b0a2c5f.1365590805.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41242 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935720Ab3DJRhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 13:37:20 -0400
In-Reply-To: <4a1dcbcfb28ea2d18b09561a370efe7a4b0a2c5f.1365590805.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-10 at 12:47 +0200, Jiri Benc wrote:
> As network adapters supporting PTP are becoming more common, machines with
> many NICs suddenly have many PHCs, too. The current limit of eight /dev/ptp*
> char devices (and thus, 8 network interfaces with PHC) is insufficient. Let
> the ptp driver allocate the char devices dynamically.
> 
> The character devices are allocated in chunks. idr is used for tracking
> minor numbers allocation; the mapping from index to pointer is not used, as
> it is not needed for posix clocks.
[...]

I don't understand why you want to dynamically allocate chunks of minor
numbers, rather than the full range.  Unused minors don't seem to cost
anything.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
