From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v4] Don't destroy the netdev until the vif is
 shut down
Date: Fri, 20 Sep 2013 08:10:25 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD010E55C@AMSPEX01CL01.citrite.net>
References: <1379436368-6882-1-git-send-email-paul.durrant@citrix.com>
 <20130919.140513.2047786411565716987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:39322 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754154Ab3ITIK1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 04:10:27 -0400
In-Reply-To: <20130919.140513.2047786411565716987.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 19 September 2013 19:05
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; David Vrabel; Wei Liu;
> Ian Campbell
> Subject: Re: [PATCH net-next v4] Don't destroy the netdev until the vif is
> shut down
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Tue, 17 Sep 2013 17:46:08 +0100
> 
> > Without this patch, if a frontend cycles through states Closing
> > and Closed (which Windows frontends need to do) then the netdev
> > will be destroyed and requires re-invocation of hotplug scripts
> > to restore state before the frontend can move to Connected. Thus
> > when udev is not in use the backend gets stuck in InitWait.
> >
> > With this patch, the netdev is left alone whilst the backend is
> > still online and is only de-registered and freed just prior to
> > destroying the vif (which is also nicely symmetrical with the
> > netdev allocation and registration being done during probe) so
> > no re-invocation of hotplug scripts is required.
> >
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> I think all of the testing requests have been satisfied so I have
> applied this.
> 
> But _please_ write a more proper subject line in future patch
> submissions.  You have to provide a subsystem prefix in the
> subject line, here I added "xen-netback: ", otherwise someone
> skimming the shortlog has no idea what area of code this change
> touches.
> 

Ok. Will do. Thanks,

  Paul
