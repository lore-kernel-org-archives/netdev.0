From: roopa <roopa@cumulusnetworks.com>
Subject: Re: ip addr add command generates error
Date: Mon, 23 Mar 2015 17:13:14 -0700
Message-ID: <5510AC1A.7050507@cumulusnetworks.com>
References: <C5551D9AAB213A418B7FD5E4A6F30A0789291C3A@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vadim4j@gmail.com" <vadim4j@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34299 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbCXANQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 20:13:16 -0400
Received: by pdbni2 with SMTP id ni2so203069700pdb.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 17:13:16 -0700 (PDT)
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0789291C3A@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/15, 3:43 PM, Rose, Gregory V wrote:
> The 'ip addr add' command used to use the following syntax:
>
> # ip addr add 10.0.0.2/24 brd 10.0.0.255 dev <eth>
>
> However, attempts to use that same command syntax with the current iproute2 tip gives the following error:
>
> Error: an inet prefix is expected rather than "20.0.0.2/24"
>
> This seems like a bug.  The commit that introduces the issue is f3a2ddc124e09d3990b836e322ed39c76c35546e by Vadim Kochan.  Reverting this commit fixes the problem.
>
> Is this change deliberate?  It would break a lot of scripts if so.
>

looked like an unintended change. This was reported a few days back and 
I hit this too in another context and a patch 
https://patchwork.ozlabs.org/patch/451210/ is in the queue.
