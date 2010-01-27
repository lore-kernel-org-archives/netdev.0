From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] starfire: clean up properly if firmware loading
 fails
Date: Tue, 26 Jan 2010 21:05:29 -0800 (PST)
Message-ID: <20100126.210529.20921693.davem@davemloft.net>
References: <201001270427.o0R4R9EQ010839@imap1.linux-foundation.org>
	<1264568297.373.482.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	michael@moffatt.org.nz, stable@kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751012Ab0A0FFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 00:05:17 -0500
In-Reply-To: <1264568297.373.482.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Jan 2010 04:58:17 +0000

> On Tue, 2010-01-26 at 20:27 -0800, akpm@linux-foundation.org wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> 
>> netdev_open() will return without cleaning up net device or hardware state
>> if firmware loading fails.  This results in a BUG() on a second attempt to
>> bring the interface up, reported in
>> <http://bugzilla.kernel.org/show_bug.cgi?id=15117>, and probably has even
>> worse effects if the driver is removed afterwards.
> 
> David, please correct the URL above before applying the patch so I don't
> continue to look like an idiot. :-)  It should be
> <http://bugzilla.kernel.org/show_bug.cgi?id=15091> as added by Andrew
> below.

Done.
