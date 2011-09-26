From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 17:41:59 +0100
Message-ID: <1317055319.2773.41.camel@bwh-desktop>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110925102353.602d239b@s6510.linuxnetplumber.net>
	 <43F901BD926A4E43B106BF17856F0755019C519385@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24632 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab1IZQmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 12:42:03 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F0755019C519385@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-09-26 at 09:21 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > Sent: Sunday, September 25, 2011 10:24 AM
> > To: Kirsher, Jeffrey T
> > Cc: Rose, Gregory V; davem@davemloft.net; netdev@vger.kernel.org;
> > gospo@redhat.com
> > Subject: Re: [net-next] iproute2: Add new command to IP link to
> > enable/disable VF spoof check
> > 
> > On Sun, 25 Sep 2011 01:23:18 -0700
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > 
> > > From: Greg Rose <gregory.v.rose@intel.com>
> > >
> > > Add IP link command parsing for VF spoof checking enable/disable
> > >
> > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > See my comments about ABI compatibility. Can't just grow size of
> > structure.
> > Need to have new version of iproute work with older kernels.
> 
> In this case I have no idea how to proceed.  I'll go back and stare at it some more.

Where is this structure used on the wire?  I just don't see it.

If the modified iproute2 crashes on older kernels, that's presumably
because it's not correctly handling the case where IFLA_VF_SPOOFCHK is
missing.  Nothing to do with the size of this structure.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
