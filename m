From: "Christian Benvenuti (benve)" <benve@cisco.com>
Subject: RE: [net-next] iproute2: Add new command to IP link to enable/disable VF spoof check
Date: Mon, 26 Sep 2011 15:54:53 -0500
Message-ID: <184D23435BECB444AB6B9D4630C8EC83028F8A71@XMB-RCD-303.cisco.com>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com><20110925102353.602d239b@s6510.linuxnetplumber.net><43F901BD926A4E43B106BF17856F0755019C519385@orsmsx508.amr.corp.intel.com><1317055319.2773.41.camel@bwh-desktop> <20110926094719.0cb6c296@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>, <gospo@redhat.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-6.cisco.com ([173.37.86.77]:35414 "EHLO
	rcdn-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493Ab1IZUyz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 16:54:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20110926094719.0cb6c296@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> Sent: Monday, September 26, 2011 9:47 AM
> To: Ben Hutchings
> Cc: Rose, Gregory V; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com
> Subject: Re: [net-next] iproute2: Add new command to IP link to
> enable/disable VF spoof check
> 
> On Mon, 26 Sep 2011 17:41:59 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > On Mon, 2011-09-26 at 09:21 -0700, Rose, Gregory V wrote:
> > > > -----Original Message-----
> > > > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > > > Sent: Sunday, September 25, 2011 10:24 AM
> > > > To: Kirsher, Jeffrey T
> > > > Cc: Rose, Gregory V; davem@davemloft.net;
netdev@vger.kernel.org;
> > > > gospo@redhat.com
> > > > Subject: Re: [net-next] iproute2: Add new command to IP link to
> > > > enable/disable VF spoof check
> > > >
> > > > On Sun, 25 Sep 2011 01:23:18 -0700
> > > > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > > >
> > > > > From: Greg Rose <gregory.v.rose@intel.com>
> > > > >
> > > > > Add IP link command parsing for VF spoof checking
> enable/disable
> > > > >
> > > > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > >
> > > > See my comments about ABI compatibility. Can't just grow size of
> > > > structure.
> > > > Need to have new version of iproute work with older kernels.
> > >
> > > In this case I have no idea how to proceed.  I'll go back and
stare
> at it some more.
> >
> > Where is this structure used on the wire?  I just don't see it.
> >
> > If the modified iproute2 crashes on older kernels, that's presumably
> > because it's not correctly handling the case where IFLA_VF_SPOOFCHK
> is
> > missing.  Nothing to do with the size of this structure.
> 
> The proposed code is fine because the vf_info is not used by any code
> in iproute right now and I doubt that any other tools are using it
> either.

Does it mean that a Netlink interface becomes official (and backward
compatibility
should not be broken) only once iproute2 starts supporting it?

/Chris
