From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next] iproute2: Add new command to IP link to
 enable/disable VF spoof check
Date: Mon, 26 Sep 2011 09:47:19 -0700
Message-ID: <20110926094719.0cb6c296@nehalam.linuxnetplumber.net>
References: <1316938998-29855-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110925102353.602d239b@s6510.linuxnetplumber.net>
	<43F901BD926A4E43B106BF17856F0755019C519385@orsmsx508.amr.corp.intel.com>
	<1317055319.2773.41.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38267 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab1IZQr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Sep 2011 12:47:29 -0400
In-Reply-To: <1317055319.2773.41.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Sep 2011 17:41:59 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2011-09-26 at 09:21 -0700, Rose, Gregory V wrote:
> > > -----Original Message-----
> > > From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> > > Sent: Sunday, September 25, 2011 10:24 AM
> > > To: Kirsher, Jeffrey T
> > > Cc: Rose, Gregory V; davem@davemloft.net; netdev@vger.kernel.org;
> > > gospo@redhat.com
> > > Subject: Re: [net-next] iproute2: Add new command to IP link to
> > > enable/disable VF spoof check
> > > 
> > > On Sun, 25 Sep 2011 01:23:18 -0700
> > > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > > 
> > > > From: Greg Rose <gregory.v.rose@intel.com>
> > > >
> > > > Add IP link command parsing for VF spoof checking enable/disable
> > > >
> > > > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > 
> > > See my comments about ABI compatibility. Can't just grow size of
> > > structure.
> > > Need to have new version of iproute work with older kernels.
> > 
> > In this case I have no idea how to proceed.  I'll go back and stare at it some more.
> 
> Where is this structure used on the wire?  I just don't see it.
> 
> If the modified iproute2 crashes on older kernels, that's presumably
> because it's not correctly handling the case where IFLA_VF_SPOOFCHK is
> missing.  Nothing to do with the size of this structure.

The proposed code is fine because the vf_info is not used by any code
in iproute right now and I doubt that any other tools are using it either.
