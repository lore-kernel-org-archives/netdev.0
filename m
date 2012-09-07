From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 4/6] igb: Store the MAC address in the name in the
 PTP struct.
Date: Fri, 7 Sep 2012 07:51:40 +0200
Message-ID: <20120907055139.GA2282@netboy.at.omicron.at>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120906080628.GD2550@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580785F9F4@ORSMSX105.amr.corp.intel.com>
 <1346973787.2714.62.camel@bwh-desktop.uk.solarflarecom.com>
 <02874ECE860811409154E81DA85FBB580785FA77@ORSMSX105.amr.corp.intel.com>
 <1346974770.2714.64.camel@bwh-desktop.uk.solarflarecom.com>
 <02874ECE860811409154E81DA85FBB580785FAB4@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64889 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2IGFvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 01:51:52 -0400
Received: by wibhi8 with SMTP id hi8so1278756wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 22:51:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580785FAB4@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 06, 2012 at 11:40:23PM +0000, Keller, Jacob E wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > 
> > The PTP clock is instantiated by some driver, bound to some device,
> > whether that's a PCI device or a platform device or something else.  I
> > think that device (not a net device) should be the parent of the clock
> > device.
> > 
> 
> Agreed, that would make the most sense.

Okay, makes sense, but that will require a change to the phc core.

For the present, I can buy Jacob's argument that the MAC address is a
way to clarify to the user that there are "unfortunate" multiple clock
instances.

Thanks,
Richard
