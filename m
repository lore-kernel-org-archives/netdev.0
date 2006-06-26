From: David Miller <davem@davemloft.net>
Subject: Re: [NETROM] Fix possible null pointer dereference.
Date: Mon, 26 Jun 2006 00:05:33 -0700 (PDT)
Message-ID: <20060626.000533.85418696.davem@davemloft.net>
References: <20060623214437.GA8463@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20927
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932386AbWFZHFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 03:05:34 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060623214437.GA8463@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 23 Jun 2006 22:44:37 +0100

> If in nr_link_failed the neighbour list is non-empty but the node list
> is empty we'll end dereferencing a  in a NULL pointer.
> 
> This fixes coverity 362.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
