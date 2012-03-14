From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [PATCH]  fix sierra_net endianess bug
Date: Wed, 14 Mar 2012 22:10:35 +0100
Message-ID: <m2pqce51o4.fsf@igel.home>
References: <4F60A695.4040601@mt.lv> <m2399bmcfq.fsf@igel.home>
	<1331753062.2564.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Maris Paupe <marisp@mt.lv>, <epasheva@sierrawireless.com>,
	<rfiler@sierrawireless.com>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:47558 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab2CNVKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 17:10:41 -0400
In-Reply-To: <1331753062.2564.6.camel@bwh-desktop.uk.solarflarecom.com> (Ben
	Hutchings's message of "Wed, 14 Mar 2012 19:24:22 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> On Wed, 2012-03-14 at 16:26 +0100, Andreas Schwab wrote:
>> Maris Paupe <marisp@mt.lv> writes:
>> 
>> > I have found that sierra_net does not work properly on big-endian
>> > systems, it works if bytes are flipped in this particular location.
>> 
>> That should probably be fixed in sierra_net_get_fw_attr (and the author
>> of sierra_net_get_fw_attr should be hit with a cluestick to not use
>> kmalloc for allocating a single u16).
>
> You cannot use stack buffers for DMA, which includes all USB I/O.

Ok, sorry, I didn't know that.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
