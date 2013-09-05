From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Thu, 5 Sep 2013 11:32:59 -0700
Message-ID: <20130905113259.55ad2ad2@nehalam.linuxnetplumber.net>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
	<FC41C24E35F18A40888AACA1A36F3E416C6249AD@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36288 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab3IESdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:33:03 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so2231918pab.21
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 11:33:02 -0700 (PDT)
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E416C6249AD@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 5 Sep 2013 17:53:38 +0000
"Nelson, Shannon" <shannon.nelson@intel.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Wednesday, September 04, 2013 5:38 PM
> 
> [...]
> 
> > Also, anything in sysfs is device specific and you really need to make
> > a strong case for why your device is special and needs an exception.
> > Other devices will have hardware switches and doing something through
> > sysfs is going to create a pain for any controller application.
> > 
> > I vote against including the sysfs VEB stuff because it will become
> > a lifetime ABI.
> 
> If we simply remove the VEB attributes (cvlan, mode, seid, svlan) but keep the model structure and the VSI attributes, will that satisfy your vote, or are you suggesting that we should drop the whole sysfs model that we implemented?
> 
> At this point after some discussion internally, we think it would be better to simply remove the whole sysfs module - it is an optional section with no direct operational requirement.  The intent was to get something started that looked useful, but perhaps we were a little premature in presenting this model for these new switch offload capabilities.
> 
> As Dave rightly pointed out, we may want to bring this back in the future, but I think that we have more work to do with the community in proposing and designing a switching model, if it really is even needed.  That's not an over-night thing, and we shouldn't be trying to patch up something that has fundamental concerns.  Also, bringing it back later when it isn't obscured by the rest of the driver might be more successful in getting community input.
> 
> sln
> 
> 

IMHO  attributes are a nice way of handling the VSI attributes since they
seem hardware specific.  Not sure how to do the right thing with switching.
Should it look like Macvlan, bridge, VXLAN, or something else.
