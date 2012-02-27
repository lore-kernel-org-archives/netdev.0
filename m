From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] ibm emac: delete module references; phy.c only
 supported as built-in
Date: Mon, 27 Feb 2012 15:49:42 -0500
Message-ID: <20120227204941.GA29529@windriver.com>
References: <1330372024-30974-1-git-send-email-paul.gortmaker@windriver.com>
 <20120227.145753.1111293673513137413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <benh@kernel.crashing.org>,
	<linuxppc-dev@lists.ozlabs.org>, <jwboyer@gmail.com>,
	<mporter@kernel.crashing.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56157 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851Ab2B0Utv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 15:49:51 -0500
Content-Disposition: inline
In-Reply-To: <20120227.145753.1111293673513137413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next] ibm emac: delete module references; phy.c only supported as built-in] On 27/02/2012 (Mon 14:57) David Miller wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 27 Feb 2012 14:47:04 -0500
> 
> > The Makefile has it as "ibm_emac-y := mal.o core.o phy.o" so there is
> > no way this can be built modular, so remove all references to module
> > support.
> 
> That doesn't mean it's only buildable statically.
> 
> "ibm_emacs-y :=" is merely a way to tell make what objects go into ibm_emac.{o,ko}
> 
> IBM_EMAC is tristate

Argh, yes.  Sorry for the noise.  Since phy.c doesn't call any modular
functionality directly, the patch "worked" and I didn't catch the
error in my reasoning.

Paul.
