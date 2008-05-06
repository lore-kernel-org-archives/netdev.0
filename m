From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Tue, 6 May 2008 13:49:13 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell> <481FB33F.3040804@acm.org> <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <akpm@linux-foundation.org>,
	"netdev" <netdev@vger.kernel.org>,
	<bugme-daemon@bugzilla.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Ben Liblit" <liblit@acm.org>, "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64419 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763559AbYEFUtZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 16:49:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
>Ben Liblit wrote:
>> Michael Chan wrote:
>>> "ethtool -C eth0 stats-block-usecs" can be used to control
statistics
>>> update frequency on most tg3 and bnx2 devices.
>> 
>> But not on my e1000-driven Intel 82566DC, sadly:

> e1000 commit ef90e4eca9fcade05dd03f853df75cf459a75422

> and for e1000e (which you should be using for 82566)
> commit 419886927796dfeca87c1fd11d1fe2ed442103cc

> I'm not sure if this patch is in 2.6.24 and my git foo is lacking...
> is this patch not working for you?  if so we need to figure out why.

I found that these commits (to do real time stats update) are in
2.6.25-rc1, not 2.6.24, it would be great if you were able to try a
newer kernel version to verify that these fixes work for you.

an ethtool -C parameter implementation to support modifiable polling
frequency for the other stats is in progress.

Jesse
