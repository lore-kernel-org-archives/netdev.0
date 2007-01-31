From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 09:16:42 -0600
Message-ID: <20070131151642.GA5318@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net> <20070131054457.GA32043@lixom.net> <200701311344.31692.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:53611 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965015AbXAaPJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 10:09:56 -0500
Content-Disposition: inline
In-Reply-To: <200701311344.31692.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jan 31, 2007 at 01:44:31PM +0100, Ingo Oeser wrote:

> You might want to write these loops like that:
[...]

> That way you:
> - Let you give other processes a chance to run, 
>   while you wait for your hardware state to change 
>   (if your hardware can tolerate these latencies).
> - can somehow handle hardware failure and at least give the user a clue
>   what is happening.

Yep, makes sense. I'll implement something like it.


Thanks,

-Olof
