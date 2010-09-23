From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [Bugme-new] [Bug 18592] New: Remote/local Denial of
 Service vulnerability in SCTP packet/chunk handling
Date: Thu, 23 Sep 2010 12:21:55 -0700 (PDT)
Message-ID: <20100923.122155.108788529.davem@davemloft.net>
References: <4C916615.4060400@hp.com>
	<201009181611.05665.dreibh@iem.uni-due.de>
	<20100923180515.GG23040@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dreibh@iem.uni-due.de, akpm@linux-foundation.org,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, martin.becke@uni-due.de,
	linux-sctp@vger.kernel.org, stable@kernel.org, sri@us.ibm.com
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55750
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756106Ab0IWTVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 15:21:36 -0400
In-Reply-To: <20100923180515.GG23040@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Thu, 23 Sep 2010 11:05:15 -0700

> On Sat, Sep 18, 2010 at 04:11:03PM +0200, Thomas Dreibholz wrote:
>> Vlad's patch solves the problem. I hope this patch can go into the mailine 
>> kernel soon, in order to get distribution kernels fixed as soon as possible. It 
>> is relatively easy to trigger the denial of service problem, making all 
>> systems providing SCTP-based services vulnerable to a remote DoS attack.
>> 
>> I have also been able to reproduce the problem with kernel 2.6.32, i.e. at 
>> least all kernels from 2.6.32 to 2.6.36 are affected.
> 
> Is this in Linus's tree now?  If so, does anyone have the git commit id?

Should be: 4bdab43323b459900578b200a4b8cf9713ac8fab
