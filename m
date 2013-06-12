From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ping_check_bind_addr() etc. can be static
Date: Wed, 12 Jun 2013 01:17:52 -0700 (PDT)
Message-ID: <20130612.011752.655896553563933294.davem@davemloft.net>
References: <20130609122426.GA2715@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011Ab3FLIR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 04:17:57 -0400
In-Reply-To: <20130609122426.GA2715@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>
Date: Sun, 9 Jun 2013 20:24:26 +0800

>  /* Checks the bind address and possibly modifies sk->sk_bound_dev_if. */
> -int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
> +static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
>  			 struct sockaddr *uaddr, int addr_len) {

In all of these cases, you have to fix the indentation of all of the
argument lines when the change the location of the openning
parenthesis of the first line of the function definition.

That's because in the networking we indent function declarations
in the following way:

int foo(int arg1, int arg2, int arg3,
	int arg4, int arg5)

Specifically, the arguments that are declared on the second and
subsequent lines must start at the first column after the openning
parenthesis.  This must be done using the appropriate number of
TAB and space characters necessary to achieve that exact column.

Please fix this up and combine your two patches into one.
