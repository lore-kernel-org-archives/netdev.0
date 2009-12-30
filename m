From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Ethernet CRC questions
Date: Wed, 30 Dec 2009 11:37:13 +0100
Message-ID: <1262169433.2247.15.camel@localhost>
References: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
	 <1262108376.5941.5.camel@localhost>
	 <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31143 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbZL3KhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 05:37:18 -0500
In-Reply-To: <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-30 at 13:53 +0800, thomas yang wrote:
> 2009/12/30 Ben Hutchings <bhutchings@solarflare.com>:
> > On Wed, 2009-12-30 at 01:17 +0800, thomas yang wrote:
> >> How does Linux  generate Ethernet CRC ?
> >> by the hardware (Ethernet controller)  or  use crc32_le() /
> >> crc32_be()     ( lib/crc32.c )  ?
> >>
> >> P.S.   my  network card is  rtl8139d  , use  8139too driver
> >
> > The Ethernet frame CRC is normally generated and verified in hardware.
> > These library functions are needed for the few MACs that don't, or where
> > the same CRC function is used for some other purpose (e.g. as a hash
> > function for multicast filtering).
> >
> 
> Does the Ethernet frame CRC (generate and verify in hardware)  make
> the TX / RX  rate  a little smaller , and a longer end-to-end  delay ?

Relative to what?

>  Could I disable CRC appending / verifying  in the network card driver
>   on all of my nodes (machines) ?

Maybe if you want switches to discard everything you send...

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

