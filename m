From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
Date: Thu, 9 Feb 2012 11:11:58 -0800
Message-ID: <20120209111158.71a6ab4a@nehalam.linuxnetplumber.net>
References: <C5551D9AAB213A418B7FD5E4A6F30A0702F874CA@ORSMSX106.amr.corp.intel.com>
	<20120209.134940.176223015646381142.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F87530@ORSMSX106.amr.corp.intel.com>
	<20120209.140137.825194006300440230.davem@davemloft.net>
	<C5551D9AAB213A418B7FD5E4A6F30A0702F8759A@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36689 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758295Ab2BITMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 14:12:00 -0500
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0702F8759A@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Feb 2012 19:06:02 +0000
"Rose, Gregory V" <gregory.v.rose@intel.com> wrote:

> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of David Miller
> > Sent: Thursday, February 09, 2012 11:02 AM
> > To: Rose, Gregory V
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [RFC PATCH] rtnetlink: Add filter for VF info dump requests
> > 
> > From: "Rose, Gregory V" <gregory.v.rose@intel.com>
> > Date: Thu, 9 Feb 2012 18:57:26 +0000
> > 
> > > I'm sure the consternation on my part is that I had thought you
> > > wanted the feature bits to default to none.  You said this at one
> > > point:
> > 
> > In "the kernel", so that things like GLIBC, that don't ask for the
> > features, no longer break with lots of VFs.
> > 
> > "iproute2" in userland can set all the feature bits, and have code
> > added to accomodate large dump requests in the future, so you're going
> > to have to make changes to iproute2 for this.
> 
> OK, that's a bit more clear to me then.  And that's the only reason I mentioned that the semantics to 'ip link show' would change.  But now I see what you mean by the rubbish comment.  By default ip link show will set all the feature bits and I'll add option code to iproute2 to allow the user to turn it off.
> 
> Does that make sense?

Please don't introduce more flags, either use the existing detail flag or
just get everything. 
