From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 03/13] ts108: use netdev_alloc_skb
Date: Fri, 30 May 2008 22:20:48 -0400
Message-ID: <4840B600.2090109@pobox.com>
References: <20080416233727.732025083@vyatta.com> <20080416233757.166190217@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Bounine <alex.bou9@gmail.com>,
	Zang Roy-r61911 <tie-fei.zang@freescale.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54355 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276AbYEaCUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:20:52 -0400
In-Reply-To: <20080416233757.166190217@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Use netdev_alloc_skb for rx buffer allocation. This sets skb->dev
> and can be overriden for NUMA machines.
> 
> This device is PowerPC only, so not tested or compiled.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

applied


