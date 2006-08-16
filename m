From: "Giacomo A. Catenazzi" <cate@debian.org>
Subject: Re: bonding: cannot remove certain named devices
Date: Wed, 16 Aug 2006 15:59:17 +0200
Message-ID: <44E324B5.4090005@debian.org>
References: <6KfTz-OX-11@gated-at.bofh.it> <6KfTA-OX-15@gated-at.bofh.it> <E1GD8rX-0001cA-CV@be1.lrz> <20060815.171002.104028951.davem@davemloft.net> <44E2BC9C.1000101@debian.org> <20060816133811.GA26471@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp1.ethz.ch ([82.130.70.13]:9850 "EHLO xsmtp1.ethz.ch")
	by vger.kernel.org with ESMTP id S1750971AbWHPN7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 09:59:23 -0400
To: "Giacomo A. Catenazzi" <cate@debian.org>,
	David Miller <davem@davemloft.net>, 7eggert@gmx.de,
	7eggert@elstempel.de, shemminger@osdl.org,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
In-Reply-To: <20060816133811.GA26471@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Nottingham wrote:
> Giacomo A. Catenazzi (cate@debian.org) said: 
>>> Are you willing to work to add the special case code necessary to
>>> handle whitespace characters in the device name over all of the kernel
>>> code and also all of the userland tools too?
>> But if you don't handle spaces in userspace, you handle *, ?, [, ], $,
>> ", ', \  in userspace? Should kernel disable also these (insane device
>> chars) chars?
> 
> Don't forget unicode characters!
> 
> Seriously, while it might be insane to use some of these, I'm wondering
> if trying to filter names is more work than fixing the tools.

Fixing tools in always the good approach, and I think in this case wrong
code is really a security problem. IMHO kernel cannot filter all bad 
strings.
So, if for the kernel part it is better to filter spaces, ok!
But we should use this user space problems as the motivation to filter
names.

ciao
	cate

