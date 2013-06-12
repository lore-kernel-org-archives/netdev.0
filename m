From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH net-next] net: ping_check_bind_addr() etc. can be static
Date: Wed, 12 Jun 2013 18:26:15 +0800
Message-ID: <20130612102615.GB13837@localhost>
References: <20130609122426.GA2715@localhost>
 <20130612.011752.655896553563933294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6638 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754301Ab3FLK0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 06:26:41 -0400
Content-Disposition: inline
In-Reply-To: <20130612.011752.655896553563933294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 01:17:52AM -0700, David Miller wrote:
> From: Fengguang Wu <fengguang.wu@intel.com>
> Date: Sun, 9 Jun 2013 20:24:26 +0800
> 
> >  /* Checks the bind address and possibly modifies sk->sk_bound_dev_if. */
> > -int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
> > +static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
> >  			 struct sockaddr *uaddr, int addr_len) {
> 
> In all of these cases, you have to fix the indentation of all of the
> argument lines when the change the location of the openning
> parenthesis of the first line of the function definition.
> 
> That's because in the networking we indent function declarations
> in the following way:
> 
> int foo(int arg1, int arg2, int arg3,
> 	int arg4, int arg5)
> 
> Specifically, the arguments that are declared on the second and
> subsequent lines must start at the first column after the openning
> parenthesis.  This must be done using the appropriate number of
> TAB and space characters necessary to achieve that exact column.
> 
> Please fix this up and combine your two patches into one.

OK I'll rework the patch, thank you for the kind tips!

Thanks,
Fengguang
