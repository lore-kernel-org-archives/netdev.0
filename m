From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Mon, 9 Mar 2015 13:53:38 -0400
Message-ID: <20150309175338.GB22009@tuxdriver.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
 <20150309140241.GI502@gospo.home.greyhouse.net>
 <CAE4R7bBwtGbB6FjJbEBXieYNRrqGknsC2FRQ2s270ySeEYNerQ@mail.gmail.com>
 <54FDCF97.3000601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41963 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbbCISAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 14:00:30 -0400
Content-Disposition: inline
In-Reply-To: <54FDCF97.3000601@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 09:51:35AM -0700, Jeff Kirsher wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA512
> 
> On 03/09/2015 09:16 AM, Scott Feldman wrote:
> > On Mon, Mar 9, 2015 at 7:02 AM, Andy Gospodarek 
> > <gospo@cumulusnetworks.com> wrote:
> >> On Sat, Mar 07, 2015 at 10:15:35PM -0800, sfeldma@gmail.com
> >> wrote:
> >>> From: Scott Feldman <sfeldma@gmail.com>
> >>> 
> >>> On ip route print dump, label externally offloaded routes with
> >>> "external". Offloaded routes are flagged with RTNH_F_EXTERNAL,
> >>> a recent additon to net-next.  For example:
> >>> 
> >>> $ ip route default via 192.168.0.2 dev eth0 11.0.0.0/30 dev
> >>> swp1  proto kernel  scope link  src 11.0.0.2 external 
> >>> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20
> >>> external 11.0.0.8/30 dev swp2  proto kernel  scope link  src
> >>> 11.0.0.10 external 11.0.0.12/30 via 11.0.0.9 dev swp2  proto
> >>> zebra  metric 20 external 12.0.0.2  proto zebra  metric 30
> >>> external nexthop via 11.0.0.1  dev swp1 weight 1 nexthop via
> >>> 11.0.0.9  dev swp2 weight 1 12.0.0.3 via 11.0.0.1 dev swp1
> >>> proto zebra  metric 20 external 12.0.0.4 via 11.0.0.9 dev swp2
> >>> proto zebra  metric 20 external 192.168.0.0/24 dev eth0  proto
> >>> kernel  scope link  src 192.168.0.15
> >>> 
> >>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> >> 
> >> You know we cannot have a thread about nomenclature without a
> >> comment from me.  ;)
> >> 
> >> My only concern about 'external' is whether or not people will
> >> gloss over it since many of the routes listed will be to networks
> >> that actually are external to the system.  That namespace
> >> collision could seem awkward if you are not a traditional
> >> follower of this list. Listing an FDB entry as 'external' does
> >> not have the same issue since all FDB entries are local to the
> >> system, so I didn't even think about the potential when that set
> >> was posted.
> >> 
> >> I would like to just call this 'hardware' since that is what we
> >> appear to be using for offload and would make it clear to the
> >> user that this route was in hardware as well as in the kernel.
> >> I'd say the same for FDB entries, too.
> >> 
> >> Scott, you have lots of experience in both traditional and Linux
> >> worlds, do you think my concern about confusion is unnecessary?
> > 
> > Votes so far: 1 for "external", 1 for "hardware", 1 for "offload"
> > or "hw".
> > 
> > Good point about confusion wrt routes to non-local networks.
> 
> My $0.02, "hardware" seems most appropriate to me.

Ditto...

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
