From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 9 Feb 2012 18:57:26 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F87530@ORSMSX106.amr.corp.intel.com>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F86E01@ORSMSX106.amr.corp.intel.com>
	<20120209.134347.615561064709168825.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
 <20120209.134940.176223015646381142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8883 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825Ab2BIS5c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:57:32 -0500
In-Reply-To: <20120209.134940.176223015646381142.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 09, 2012 10:50 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Thu, 9 Feb 2012 18:45:59 +0000
> 
> >> -----Original Message-----
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Thursday, February 09, 2012 10:44 AM
> >> To: Rose, Gregory V
> >> Cc: netdev@vger.kernel.org
> >> Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump
> requests
> >>
> >> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> >> Date: Thu, 9 Feb 2012 16:25:31 +0000
> >>
> >> > That will change the semantics to the 'ip link show' command quite a
> >> bit.
> >>
> >> I think that's rubbish.
> >>
> >> You can make "ip link show" do whatever you want, including setting all
> >> feature bits in getlink requests, which will preserve existing
> behavior.
> >
> > But there will be a change to the command line semantics no?  How do
> > I communicate which feature bits to set in getlink requests
> > otherwise?
> 
> Make "ip" internally default to "all" feature bits.  I don't really
> understand what the consternation is.  Right now, that's what happens,
> the kernel dumps all the attributes including "VF" stuff.
> 

I'm sure the consternation on my part is that I had thought you wanted the feature bits to default to none.  You said this at one point:

---------
It seems clear that we must, at this point, turn off VF attributes by default.
---------

I'm sorry if I seem obtuse but I'm completely confused now.

And if we default all the feature bits for VFs, macvlans, etc. to on then it seems to me there has to be some way to turn them off from user space.

- Greg
