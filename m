From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 12 May 2008 01:42:34 -0500
Message-ID: <4827E6DA.2050503@acm.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell> <481FB33F.3040804@acm.org> <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com> <36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp113.sbc.mail.mud.yahoo.com ([68.142.198.212]:42403 "HELO
	smtp113.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755026AbYELGml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 02:42:41 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg wrote:
> I found that these commits (to do real time stats update) are in
> 2.6.25-rc1, not 2.6.24, it would be great if you were able to try a
> newer kernel version to verify that these fixes work for you.

I'm now running a self-built 2.6.25.3 kernel.  I confirm that rx_bytes 
updates as frequently as I'm reasonably able to check it.

Furthermore, the e1000e driver included with 2.5.25.3 works on my 
hardware when using this kernel.  Both e1000 and e1000e work, and 
rx_bytes is updated promptly when using either driver.

Problem solved.
