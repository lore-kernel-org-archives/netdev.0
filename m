From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: ip addr add command generates error
Date: Tue, 24 Mar 2015 10:09:01 +0200
Message-ID: <20150324080901.GA724@angus-think.wlc.globallogic.com>
References: <C5551D9AAB213A418B7FD5E4A6F30A0789291C3A@ORSMSX108.amr.corp.intel.com>
 <5510AC1A.7050507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vadim4j@gmail.com" <vadim4j@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:36068 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbbCXIUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 04:20:55 -0400
Received: by labe2 with SMTP id e2so77975498lab.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 01:20:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5510AC1A.7050507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 05:13:14PM -0700, roopa wrote:
> On 3/23/15, 3:43 PM, Rose, Gregory V wrote:
> >The 'ip addr add' command used to use the following syntax:
> >
> ># ip addr add 10.0.0.2/24 brd 10.0.0.255 dev <eth>
> >
> >However, attempts to use that same command syntax with the current iproute2 tip gives the following error:
> >
> >Error: an inet prefix is expected rather than "20.0.0.2/24"
> >
> >This seems like a bug.  The commit that introduces the issue is f3a2ddc124e09d3990b836e322ed39c76c35546e by Vadim Kochan.  Reverting this commit fixes the problem.
> >
> >Is this change deliberate?  It would break a lot of scripts if so.
> >
> 
> looked like an unintended change. This was reported a few days back and I
> hit this too in another context and a patch
> https://patchwork.ozlabs.org/patch/451210/ is in the queue.

I apologize for this stupid mistake!

Regards,
