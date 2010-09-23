From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [Bugme-new] [Bug 18592] New: Remote/local Denial of
 Service vulnerability in SCTP packet/chunk handling
Date: Thu, 23 Sep 2010 12:37:39 -0700
Message-ID: <20100923193739.GA2809@kroah.com>
References: <4C916615.4060400@hp.com>
 <201009181611.05665.dreibh@iem.uni-due.de>
 <20100923180515.GG23040@kroah.com>
 <20100923.122155.108788529.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dreibh@iem.uni-due.de, akpm@linux-foundation.org,
	vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, martin.becke@uni-due.de,
	linux-sctp@vger.kernel.org, stable@kernel.org, sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:58807 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754994Ab0IWTiR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Sep 2010 15:38:17 -0400
Content-Disposition: inline
In-Reply-To: <20100923.122155.108788529.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 12:21:55PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Thu, 23 Sep 2010 11:05:15 -0700
> 
> > On Sat, Sep 18, 2010 at 04:11:03PM +0200, Thomas Dreibholz wrote:
> >> Vlad's patch solves the problem. I hope this patch can go into the mailine 
> >> kernel soon, in order to get distribution kernels fixed as soon as possible. It 
> >> is relatively easy to trigger the denial of service problem, making all 
> >> systems providing SCTP-based services vulnerable to a remote DoS attack.
> >> 
> >> I have also been able to reproduce the problem with kernel 2.6.32, i.e. at 
> >> least all kernels from 2.6.32 to 2.6.36 are affected.
> > 
> > Is this in Linus's tree now?  If so, does anyone have the git commit id?
> 
> Should be: 4bdab43323b459900578b200a4b8cf9713ac8fab

Wonderful, now queued up.

thanks,

greg k-h
