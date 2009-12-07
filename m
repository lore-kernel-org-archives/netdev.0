From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [Bugme-new] [Bug 14748] New: e1000e NIC not working after
 reboot
Date: Mon, 7 Dec 2009 14:01:20 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.0912071354481.2420@jbrandeb-mobl2.amr.corp.intel.com>
References: <bug-14748-10286@http.bugzilla.kernel.org/> <20091207135028.0c33a4f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "macieks@freesco.pl" <macieks@freesco.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46769 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965102AbZLGWBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 17:01:15 -0500
In-Reply-To: <20091207135028.0c33a4f4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 7 Dec 2009, Andrew Morton wrote:
> > When I power up my system the NIC is working properly.
> > After every reboot the NIC is not working. I mean the eth0 is created, but
> > neither dhcpcd gets IP nor static setup helps

We have a userspace tool called ethregs downloadable from 
http://downloads.sourceforge.net/project/e1000/Register%20Dump%20Tool/1.7.2/ethregs-1.7.2.tar.gz?use_mirror=iweb

if it is not too much trouble can you build this tool and run it before 
(when the port is working) and after (when the link didn't come up)

you can attach them to the bug, and reply to this thread would be best.

also please include the output of lspci -vvv after the failure.

Thanks,
  Jesse
