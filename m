From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ip addr add command generates error
Date: Tue, 24 Mar 2015 00:33:02 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0789291D62@ORSMSX108.amr.corp.intel.com>
References: <C5551D9AAB213A418B7FD5E4A6F30A0789291C3A@ORSMSX108.amr.corp.intel.com>
 <5510AC1A.7050507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vadim4j@gmail.com" <vadim4j@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18844 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752173AbbCXAdE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 20:33:04 -0400
In-Reply-To: <5510AC1A.7050507@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> -----Original Message-----
> From: roopa [mailto:roopa@cumulusnetworks.com]
> Sent: Monday, March 23, 2015 5:13 PM
> To: Rose, Gregory V
> Cc: stephen.hemminger@vyatta.com; netdev@vger.kernel.org;
> vadim4j@gmail.com; Brandeburg, Jesse
> Subject: Re: ip addr add command generates error
> 
> On 3/23/15, 3:43 PM, Rose, Gregory V wrote:
> > The 'ip addr add' command used to use the following syntax:
> >
> > # ip addr add 10.0.0.2/24 brd 10.0.0.255 dev <eth>
> >
> > However, attempts to use that same command syntax with the current
> iproute2 tip gives the following error:
> >
> > Error: an inet prefix is expected rather than "20.0.0.2/24"
> >
> > This seems like a bug.  The commit that introduces the issue is
> f3a2ddc124e09d3990b836e322ed39c76c35546e by Vadim Kochan.  Reverting this
> commit fixes the problem.
> >
> > Is this change deliberate?  It would break a lot of scripts if so.
> >
> 
> looked like an unintended change. This was reported a few days back and I
> hit this too in another context and a patch
> https://patchwork.ozlabs.org/patch/451210/ is in the queue.

Patch looks good.

Thanks!

- Greg
