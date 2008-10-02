From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity is exceeded
Date: Thu, 2 Oct 2008 11:16:31 +0400
Message-ID: <20081002071631.GB20406@2ka.mipt.ru>
References: <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org> <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com> <20080930184249.GC6496@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39171 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbYJBHSM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2008 03:18:12 -0400
Content-Disposition: inline
In-Reply-To: <20080930184249.GC6496@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Sep 30, 2008 at 02:42:49PM -0400, Neil Horman (nhorman@tuxdriver.com) wrote:
> I think what you're looking for here is a simple standard deviation, isn't it?
> Compute the mean chain legnth, sum the squares of the deviations of each chain
> and take the square root.  Any individual chain longer than the mean chain
> length + 1 standard deviation can be considered an 'outlier' and therefore
> trigger a rebuild of the table for that net namespace.
> 
> I full well realize that thats easier said than done, but does that seem about
> right?  If so, I can start working on trying to build something to accomplish
> that.

You are right, but in kernel it may not that simple to get a square
root... We can probably play with logarithms though.

-- 
	Evgeniy Polyakov
