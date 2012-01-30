From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: Regression: "rtnetlink: Compute and store minimum ifinfo dump
 size" breaks glibc's getifaddrs()
Date: Mon, 30 Jan 2012 17:02:51 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A07012CCFA5@ORSMSX106.amr.corp.intel.com>
References: <4F229A5F.4050600@citrix.com>
	<20120127.165357.462031319592012792.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A07012CCF52@ORSMSX106.amr.corp.intel.com>
 <20120130.115800.2216939902996648062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"steweg@gmail.com" <steweg@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46124 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab2A3RDp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:03:45 -0500
In-Reply-To: <20120130.115800.2216939902996648062.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, January 30, 2012 8:58 AM
> To: Rose, Gregory V
> Cc: david.vrabel@citrix.com; netdev@vger.kernel.org; steweg@gmail.com
> Subject: Re: Regression: "rtnetlink: Compute and store minimum ifinfo dump
> size" breaks glibc's getifaddrs()
> 
> From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> Date: Mon, 30 Jan 2012 16:50:58 +0000
> 
> > Maybe we should have 'ip link show' just display the number of VFs
> > and then have a new 'ip' tool syntax along the lines of 'ip link
> > show eth(x) vf (n)' where eth(x) is the PF and n is the number of
> > the VF.  Then it could show all relevant information for just that
> > VF.  Scripts could parse the number of VFs from the first call to
> > 'ip link show' and then loop to show the details of each VF.
> >
> > Just an idea... maybe there are other ones out there but it's just
> > getting ridiculous how much data has to be transferred back and
> > forth during the basic 'ip link show' command when the interface as
> > subordinate VFs now that we're getting to devices with up to 256
> > VFs.
> 
> The fix is almost certainly that we need to require that the application
> turn on the publishing of features it is interested in.
> 
> The inet_diag sockets do something like this, wherein you set bits in
> some flags of the request saying what attributes you want to see.
> 
> It seems clear that we must, at this point, turn off VF attributes by
> default.
> 
> Could you do some work on this?  If you don't have the time I'll look
> into it, because we'll need to backport this to -stable too.

Yeah, I can push out some other things I'm working on to get on this.

- Greg

> 
> Thanks.
