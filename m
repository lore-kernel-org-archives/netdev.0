From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 driver and samba
Date: Thu, 20 Sep 2007 00:53:27 -0400
Message-ID: <20070920005327.3f55725a.billfink@mindspring.com>
References: <780b6f780709171158h1016b6c2kfbc977b4ea7c715c@mail.gmail.com>
	<36D9DB17C6DE9E40B059440DB8D95F5203592D77@orsmsx418.amr.corp.intel.com>
	<20070918020358.d50653d5.billfink@mindspring.com>
	<ygfps0g8lj0.fsf@janus.isnogud.escape.de>
	<82k5qoxfbk.fsf@mid.bfk.de>
	<780b6f780709180932j5944b927p44ace42833e0230b@mail.gmail.com>
	<08FE5CC30C9A3F41BF819A502CF7BF6E02045257@fmsmsx411.amr.corp.intel.com>
	<780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"Florian Weimer" <fweimer@bfk.de>,
	"Urs Thuermann" <urs@isnogud.escape.de>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"James Chapman" <jchapman@katalix.com>, netdev@vger.kernel.org
To: "L F" <lfabio.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:40740 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750719AbXITExl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 00:53:41 -0400
In-Reply-To: <780b6f780709190753qd52d099id937a6c75e5d560e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007, L F wrote:

> Well,
> the issue seems to have gone away as of this morning, but I am
> somewhat unsure as to why.
> Placement of some things were modified so as to allow shorter cables.
> Now there are 3' CAT6 cables everywhere except for the 15' cable
> between the two switches. All the cables are new, high quality
> 'tested' cables from a company nearby.
> The server is now running 2.6.22.6 with the 7.6.5 e1000 driver from
> intel.com and samba 3.0.26-1 ... and it seems to work. Samba will not
> disconnect, even with all 8 clients running unreasonable read/write
> loads and CRC and MD5 checksums of the transferred files all match.
> The issue therefore seems to have gone away, but the reason why still
> escapes me. I cannot believe that CAT5 cables under 10' in length were
> causing it, because if that were the case
> 1) it would've shown itself, I presume, from the beginning
> 2) I could name dozens of different locations which would be having
> the same problems
> Samba 3.0.25 was definitely part of the problem and I sent a nice
> nastygram to the debian maintainers, because -testing is not
> -unstable, last I checked.
> As to samba having any sort of data integrity capability, to the best
> of my knowledge that has never been the case.
> To answer further questions: I checked for file integrity with
> CRC/CRC32/MD5 checksum utilities. They used to fail fairly
> consistently, they have been fine all this morning.

By any chance did you happen to power cycle some equipment in this
process that you didn't previously power cycle during earlier testing
and debugging?  If so, perhaps that hardware had somehow gotten into
a funky state, and the power cycling might have cleared it up.

Just a thought.

						-Bill
