From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Fri, 01 Feb 2008 20:57:44 +0100
Message-ID: <47A379B8.1040604@aei.mpg.de>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<47A0C5B2.1000500@hp.com> <47A1B294.8080609@aei.mpg.de> <47A20BA1.8070206@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:56263 "EHLO welcomes-you.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755338AbYBAT6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 14:58:03 -0500
In-Reply-To: <47A20BA1.8070206@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all

Rick Jones wrote:
> 2) use the aforementioned "burst" TCP_RR test.  This is then a single 
> netperf with data flowing both ways on a single connection so no issue 
> of skew, but perhaps an issue of being one connection and so one process 
> on each end.

Since our major gaol is to establish a reliable way to test duplex 
connections this looks like a very good choice. Right now we just run 
this on a back to back test (cable connecting two hosts), but want to 
move to a high performance network with up to three switches between 
hosts. For this we want to have a stable test.

I doubt that I will be able to finish the tests tonight, but I'll post a 
follow-up latest on Monday.

Have a nice week-end and thanks a lot for all the suggestions so far!

Cheers

Carsten
