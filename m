From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] genetlink: add auto module loading
Date: Wed, 28 Dec 2011 11:02:08 -0800
Message-ID: <20111228110208.5f6de3d8@nehalam.linuxnetplumber.net>
References: <20111228101958.2326b7cc@nehalam.linuxnetplumber.net>
	<20111228.134939.1155715366574563784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52644 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754166Ab1L1TCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 14:02:10 -0500
In-Reply-To: <20111228.134939.1155715366574563784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Dec 2011 13:49:39 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 28 Dec 2011 10:19:58 -0800
> 
> > When testing L2TP support, I discovered that the l2tp module is not autoloaded
> > as are other netlink interfaces. There is because of lack of hook in genetlink to call
> > request_module and load the module.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Applied, but for completeness we should probably also handle the "by ID" case right
> above this code block too.
> 
> Could you please submit a patch for that?
> 
> Thanks.

There is no point really. All the existing drivers,
use GENL_ID_GENERATE which generates the ID when they are loaded.
Chicken and egg principle.
