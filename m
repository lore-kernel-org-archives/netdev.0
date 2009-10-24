From: David Miller <davem@davemloft.net>
Subject: Re: Irq architecture for multi-core network driver.
Date: Sat, 24 Oct 2009 06:23:39 -0700 (PDT)
Message-ID: <20091024.062339.83445567.davem@davemloft.net>
References: <4AE0D14B.1070307@caviumnetworks.com>
	<4AE0D72A.4090607@nortel.com>
	<4AE0DB98.1000101@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: ddaney@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45436
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753361AbZJXNXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:23:16 -0400
In-Reply-To: <4AE0DB98.1000101@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <ddaney@caviumnetworks.com>
Date: Thu, 22 Oct 2009 15:24:24 -0700

> Certainly this is one mode of operation that should be supported, but
> I would also like to be able to go for raw throughput and have as many
> cores as possible reading from a single queue (like I currently have).

You can't do this, at least within the same flow, since as you even
mention in your original posting this can result in packet reordering
which we must avoid as much as is possible.
