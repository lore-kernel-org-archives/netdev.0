From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Sun, 21 Feb 2010 22:39:32 -0800 (PST)
Message-ID: <20100221.223932.39195123.davem@davemloft.net>
References: <201002192152.o1JLqcB6031953@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38260
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739Ab0BVGjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 01:39:14 -0500
In-Reply-To: <201002192152.o1JLqcB6031953@blc-10-1.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This driver still needs a lot of work.

The number of headers files is rediculious and I see pieces of
information duplicated up to 4 or 5 times (!?!??!)

First, reduce the header files to say two or three.

Next, remove all of the duplicated information.  You have at least two
copies of the PCI device ID in these header files.  There are three or
four definitions of the same statistics data structures.

It's pure bloat, you have to consolidate the content and the number of
header files holding this information.
