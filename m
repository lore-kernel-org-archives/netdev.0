From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH RFC 0/2] Control VF link state
Date: Tue, 21 May 2013 14:43:07 -0700
Message-ID: <519BEA6B.4080600@intel.com>
References: <1368020717-22194-1-git-send-email-ogerlitz@mellanox.com> <1368113074.2653.2.camel@bwh-desktop.uk.solarflarecom.com> <CAJZOPZJ052r67==xXciyoTmE8TQwXyx5sVgeuR=dQUEpXkd5WQ@mail.gmail.com> <1368146064.4131.279.camel@deadeye.wl.decadent.org.uk> <CAJZOPZ+c4HDbd+983qosp+NOmpZ-U3sCWKyKZrEVW_UDhfMEWA@mail.gmail.com> <1369082231.4616.15.camel@bwh-desktop.uk.solarflarecom.com> <CAJZOPZJpPjqxX__+P0eN=XatC8pzY7zJZBQcc3U6tjQycdKB5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>, netdev@vger.kernel.org,
	amirv@mellanox.com, ronye@mellanox.com
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15439 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751457Ab3EUVnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 17:43:08 -0400
In-Reply-To: <CAJZOPZJpPjqxX__+P0eN=XatC8pzY7zJZBQcc3U6tjQycdKB5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> The risk I see with extensible operations (and which has occurred with
>> many ethtool operations) is that drivers may quietly ignore the elements
>> they don't implement.  So either (1) add yet another specific operation
>> or (2) define a general VF setter, require drivers to set some flags
>> that indicate which VF attributes are settable, and check the flags in
>> rtnetlink.c before calling into the driver.
>
> both (1) and (2) makes sense to me, I am more leaned to (2), John, do
> we have a go from your side to post V1 for net-next? which of the
> options makes more sense to you?
>
> Or.
>

Either is fine if you prefer (2) that works for me. I'll get it
working with ixgbe after you post it.

.John
