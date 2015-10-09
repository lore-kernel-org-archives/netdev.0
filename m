From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-next v2 0/4] make non-modular code explicitly
 non-modular
Date: Fri, 09 Oct 2015 07:52:57 -0700 (PDT)
Message-ID: <20151009.075257.1072002884119004986.davem@davemloft.net>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, anish@chelsio.com,
	kraig@google.com, daniel@iogearbox.net, edumazet@google.com,
	jhs@mojatatu.com, john.r.fastabend@intel.com,
	nicolas.dichtel@6wind.com, ogerlitz@mellanox.com,
	shanim@mellanox.com, varkabhadram@gmail.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbbJIOhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 10:37:09 -0400
In-Reply-To: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 7 Oct 2015 17:27:42 -0400

> [v2: drop m68k patches that Geert converted to modules; add one ARM
>  driver patch ; update net-next baseline to today; switch to ARM
>  for build testing.]
> 
> In a previous merge window, we made changes to allow better
> delineation between modular and non-modular code in commit
> 0fd972a7d91d6e15393c449492a04d94c0b89351 ("module: relocate module_init
> from init.h to module.h").  This allows us to now ensure module code
> looks modular and non-modular code does not accidentally look modular
> just to avoid suffering build breakage.
> 
> Here we target code that is, by nature of their Makefile and/or
> Kconfig settings, only available to be built-in, but implicitly
> presenting itself as being possibly modular by way of using modular
> headers, macros, and functions.
> 
> The goal here is to remove that illusion of modularity from these
> files, but in a way that leaves the actual runtime unchanged.
> In doing so, we remove code that has never been tested and adds
> no value to the tree.  And we continue the process of expecting a
> level of consistency between the Kconfig/Makefile of code and the
> code in use itself.
> 
> Fortuntately the net subsystem has relatively few instances, given
> the overall amount of code and drivers it contains.  For comparison
> there are over 300 instances tree wide, resulting in a possible net
> removal of on the order of 5000 lines of unused code.
> 
> Build tested on net-next from today, on ARM, since that is the arch
> where the one ethernet driver changed here is available.

Series applied, thanks Paul.
