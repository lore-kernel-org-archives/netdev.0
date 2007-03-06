From: Andi Kleen <andi@firstfloor.org>
Subject: Re: many sockets, slow sendto
Date: 06 Mar 2007 20:23:55 +0100
Message-ID: <p73bqj6b2gk.fsf@bingen.suse.de>
References: <E1HObHK-0000WB-00@osiris.swi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Zaccomer Lajos <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:42420 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965560AbXCFSYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 13:24:33 -0500
In-Reply-To: <E1HObHK-0000WB-00@osiris.swi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zaccomer Lajos <zacco@fw.hu> writes:

> I'm playing around with a simulation, in which many thousands of IP
> 
> addresses (on interface aliases) are used to send/receive TCP/UDP

Something seems to be wrong with your emailer. It adds a empty
line between each real line.

> 
> packets. I noticed that the time of send/sendto increased linearly
> 
> with the number of file descriptors, and I found it rather strange.

Yes that is strange. I would suggest you use oprofile to identify which
parts of the kernel use the CPU time with many descriptors.

-Andi
