From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 30 May 2007 12:01:12 -0700
Message-ID: <20070530120112.63aac6cd@freepuppy>
References: <20070530131123.10843.0@janus.isnogud.escape.de>
	<20070530131204.10843.5@janus.isnogud.escape.de>
	<20070530102810.1689119b@freepuppy>
	<465DC91D.1030104@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:59835 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120AbXE3TNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:13:19 -0400
In-Reply-To: <465DC91D.1030104@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 20:57:33 +0200
Oliver Hartkopp <oliver@hartkopp.net> wrote:

>
> 
> Does 'unneeded' belong to always the last line of the quoted code snippet?
> 

They are all places where you assign zero (or NULL) to something that is
already initialized to zero by alloc_netdev.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
