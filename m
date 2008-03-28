From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 02/21] drivers/net/3c501.c: replace init_module&cleanup_module with module_init&module_exit
Date: Fri, 28 Mar 2008 21:47:55 +0000
Message-ID: <20080328214755.GE10722@ZenIV.linux.org.uk>
References: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, jkschind@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43904 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755220AbYC1VsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:48:05 -0400
Content-Disposition: inline
In-Reply-To: <200803282141.m2SLfGGa011804@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 02:41:16PM -0700, akpm@linux-foundation.org wrote:

> Replace init_module and cleanup_module with static functions and
> module_init/module_exit.

Would the esteemed sir bother to build the resulting tree with drivers
in question non-modular?

Damnit, people, try to think for a minute.  If these functions were
not called directly in non-modular case, the driver would not work
built-in.  Which is not apriori impossible, but might warrant some
further investigation.  Use of grep, for starters...

IOW, please unapply the patches in question.
