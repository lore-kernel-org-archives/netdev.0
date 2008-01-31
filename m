From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 18:27:01 +0100
Message-ID: <47A204E5.7060406@aei.mpg.de>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com> <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com> <47A1E553.8010006@aei.mpg.de> <36D9DB17C6DE9E40B059440DB8D95F52044F8EC9@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce Allen <ballen@gravity.phys.uwm.edu>, netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:55915 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756136AbYAaR1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 12:27:12 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52044F8EC9@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Brandeburg, Jesse wrote:
>>> I would suggest you try TCP_RR with a command line something like
>>> this: netperf -t TCP_RR -H <hostname> -C -c -- -b 4 -r 64K
>> I did that and the results can be found here:
>> https://n0.aei.uni-hannover.de/wiki/index.php/NetworkTest
> 
> seems something went wrong and all you ran was the 1 byte tests, where
> it should have been 64K both directions (request/response).
>  

Yes, shell-quoting got me there. I'll re-run the tests, so please don't 
look at the TCP_RR results too closely. I think I'll be able to run 
maybe one or two more tests today, rest will follow tomorrow.

Thanks for bearing with me

Carsten

PS: Am I right that the TCP_RR tests should only be run on a single node 
at a time, not on both ends simultaneously?
