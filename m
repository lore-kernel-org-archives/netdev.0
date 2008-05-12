From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 12 May 2008 00:44:39 -0500
Message-ID: <4827D947.8090804@acm.org>
References: <bug-10600-10286@http.bugzilla.kernel.org/> <20080505155502.3fb16590.akpm@linux-foundation.org> <20080505.161806.267621711.davem@davemloft.net> <481F9E64.6070606@acm.org> <1210036624.7941.183.camel@dell> <481FB33F.3040804@acm.org> <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com> <36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.re3.yahoo.com ([66.196.96.96]:28955 "HELO
	smtp123.sbc.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751551AbYELFvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 01:51:23 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Brandeburg wrote:
> and for e1000e (which you should be using for 82566)

That seems unlikely.  When I replace "alias eth0 e1000" with "alias eth0 
e100e" in my module configuration I lose the network interface entirely. 
  "ip link" does not mention it and it does not appear in 
"/sys/class/net".  Switching back to "alias eth0 e1000" restores the 
ability to use the network interface.

It seems pretty clear from my end that the e1000e driver is *not* 
recognizing and driving my Intel 82566DC ethernet device.
