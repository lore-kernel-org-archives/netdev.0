From: Harald Welte <laforge@gnumonks.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 14:43:37 +0200
Message-ID: <20091018124337.GE27747@prithivi.gnumonks.org>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
 <20091014203640.GB32317@ioremap.net>
 <4AD64251.50903@candelatech.com>
 <20091014.144923.112167161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, zbr@ioremap.net, deri@ntop.org,
	shemminger@vyatta.com, brad.doctor@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:60311 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754437AbZJRMrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:47:18 -0400
Content-Disposition: inline
In-Reply-To: <20091014.144923.112167161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Wed, Oct 14, 2009 at 02:49:23PM -0700, David Miller wrote:

> > Maybe something similar to the attached patch?
> 
> This is not something I'm interested in applying.
> 
> It makes implementing proprietary complete networking stacks
> for Linux way too easy.

How does it make it any easier?  Even right now you can implement an entire
protocol family in your own module, either by registering as netpoll handler,
or even using the regular dev_add_pack().

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
