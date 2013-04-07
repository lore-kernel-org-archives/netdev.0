From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] netxen_nic: Bug fixes and enhancement
Date: Sun, 07 Apr 2013 16:53:27 -0400 (EDT)
Message-ID: <20130407.165327.813132392224223327.davem@davemloft.net>
References: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58270 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934298Ab3DGUx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 16:53:29 -0400
In-Reply-To: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Fri,  5 Apr 2013 08:36:39 -0400

>   netxen_nic: Add module parameters support to switch interrupts

I'm not letting you add more module parameters to this driver,
sorry.

You guys really have to define reasonable infrastructure for
these sorts of interrupt configurations that all drivers use.

It must be a facility which uses a reasonable configuration mechanism,
which can be standardized across all drivers.

Module parameters do not meet those requirements.

I've rejected this entire patch series, you'll need to resubmit
it without the module parameter change.
