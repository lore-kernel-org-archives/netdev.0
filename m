From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, 2.6.24-rc1] sysfs: duplicate filename 'eth0' can not be
	created
Date: Mon, 29 Oct 2007 22:48:50 +0100
Message-ID: <20071029214850.GA31152@elte.hu>
References: <20071029211746.GA19876@elte.hu> <20071029144016.06c03b7c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37333 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbXJ2VtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 17:49:01 -0400
Content-Disposition: inline
In-Reply-To: <20071029144016.06c03b7c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Stephen Hemminger <shemminger@linux-foundation.org> wrote:

> Already fixed post 2.6.24-rc1
> 
> commit c8d90dca3211966ba5189e0f3d4bccd558d9ae08
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Fri Oct 26 03:53:42 2007 -0700
> 
>     [NET] dev_change_name: ignore changes to same name

ah, nice - that explains it. I just booted with very latest -git and the 
warning is gone.

	Ingo
