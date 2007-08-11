From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 9/24] make atomic_read() behave consistently on ia64
Date: Sat, 11 Aug 2007 10:35:08 +1000
Message-ID: <18109.1084.917429.585224@cargo.ozlabs.ibm.com>
References: <20070809135107.GA15985@shell.boston.redhat.com>
	<617E1C2C70743745A92448908E030B2A02213B3C@scsmsx411.amr.corp.intel.com>
	<46BCC1AF.5050204@redhat.com>
	<617E1C2C70743745A92448908E030B2A0224C777@scsmsx411.amr.corp.intel.com>
	<jewsw3oyl8.fsf@sykes.suse.de>
	<617E1C2C70743745A92448908E030B2A0224C88B@scsmsx411.amr.corp.intel.com>
	<46BCE9F8.4060009@redhat.com>
	<617E1C2C70743745A92448908E030B2A0224C8D7@scsmsx411.amr.corp.intel.com>
	<alpine.LFD.0.999.0708101607130.30176@woody.linux-foundation.org>
	<46BCF19E.5000702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Luck, Tony" <tony.luck@intel.com>,
	Andreas Schwab <schwab@suse.de>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37305 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757452AbXHKAgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 20:36:09 -0400
In-Reply-To: <46BCF19E.5000702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook writes:

> I'll do this for the whole patchset.  Stay tuned for the resubmit.

Could you incorporate Segher's patch to turn atomic_{read,set} into
asm on powerpc?  Segher claims that using asm is really the only
reliable way to ensure that gcc does what we want, and he seems to
have a point.

Paul.
