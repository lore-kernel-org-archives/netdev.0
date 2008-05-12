From: Ben Liblit <liblit@acm.org>
Subject: Re: [Bugme-new] [Bug 10600] New: e1000 updates rx_bytes infrequently
Date: Mon, 12 May 2008 01:26:06 -0500
Message-ID: <4827E2FE.1040109@acm.org>
References: <36D9DB17C6DE9E40B059440DB8D95F52051AAF84@orsmsx418.amr.corp.intel.com>	<36D9DB17C6DE9E40B059440DB8D95F52051AB314@orsmsx418.amr.corp.intel.com>	<4827D947.8090804@acm.org> <20080511.231806.193710614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, mchan@broadcom.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, john.ronciak@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.sbc.mail.re2.yahoo.com ([68.142.229.101]:33044 "HELO
	smtp104.sbc.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752144AbYELGct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 02:32:49 -0400
In-Reply-To: <20080511.231806.193710614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> You're missing a zero in that string, it's "e1000e" not "e100e", and
> did you make sure to enable CONFIG_E1000E in your kernel config?

Sorry, that was a typo in my comment but not in my actual experiments. 
I used "e1000e", not "e100e".  CONFIG_E1000E is enabled, and "lsmod" 
confirmed that the e1000e module was definitely loaded into the kernel. 
  "The kernel", for the record, is the current Fedora 8 kernel, 
2.6.24.5-85.fc8.

I realize that pristine, self-built kernels are preferred for bug 
reporting.  I am currently building my own 2.6.25.3 so that I can affirm 
or refute Jesse Brandeburg's claim (comment #12) that this bug is fixed 
in 2.6.25-rc1 and later.  I'll report my findings when available, 
assuming I still remember how to install my own kernels.  (Yes, yes, 
I've gotten soft and lazy.)
