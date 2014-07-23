From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [net-next 05/10] net: Add Geneve tunneling protocol driver
Date: Wed, 23 Jul 2014 10:11:26 -0400
Message-ID: <20140723141126.GB14162@tuxdriver.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
 <1406024393-6778-6-git-send-email-azhou@nicira.com>
 <53CEEFDB.5030900@intel.com>
 <CAEP_g=82H_h85Cog5HNP9P4M5LPJ=ZLz-dzLocAUKAG7cZi7yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Andy Zhou <azhou@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56024 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbaGWOPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 10:15:20 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=82H_h85Cog5HNP9P4M5LPJ=ZLz-dzLocAUKAG7cZi7yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 07:24:20PM -0400, Jesse Gross wrote:
> On Tue, Jul 22, 2014 at 7:12 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
> > On 07/22/2014 03:19 AM, Andy Zhou wrote:
> >> This adds a device level support for Geneve -- Generic Network
> >> Virtualization Encapsulation. The protocol is documented at
> >> http://tools.ietf.org/html/draft-gross-geneve-00
> >>
> >> Only protocol layer Geneve support is provided by this driver.
> >> Openvswitch can be used for configuring, set up and tear down
> >> functional Geneve tunnels.
> >>
> >> Signed-off-by: Jesse Gross <jesse@nicira.com>
> >> Signed-off-by: Andy Zhou <azhou@nicira.com>
> >> ---
> >>  include/net/geneve.h     |   85 +++++++++++++++
> >>  include/net/ip_tunnels.h |    2 +
> >>  net/ipv4/Kconfig         |   14 +++
> >>  net/ipv4/Makefile        |    1 +
> >>  net/ipv4/geneve.c        |  273 ++++++++++++++++++++++++++++++++++++++++++++++
> >>  net/openvswitch/Kconfig  |   11 ++
> >>  net/openvswitch/vport.c  |    3 +
> >>  7 files changed, 389 insertions(+)
> >>  create mode 100644 include/net/geneve.h
> >>  create mode 100644 net/ipv4/geneve.c
> >>
> >
> > So all this is really doing is enabling a Geneve socket for use by
> > Openvswitch.  Do you have any plans to enable a stand alone interface
> > like what we already have for VXLAN?
> 
> Yes, this is the basic protocol code that would be shared by all users
> of Geneve. OVS is the first user but John Linville is looking at
> adding support for connecting this to 'ip' as a non-OVS user.

ACK

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
