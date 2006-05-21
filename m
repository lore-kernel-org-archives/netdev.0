From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [git patches] net driver updates
Date: Sun, 21 May 2006 09:11:46 +0200
Message-ID: <447012B2.9050207@colorfullife.com>
References: <20060520042856.GA7218@havoc.gtf.org> <Pine.LNX.4.64.0605201035510.10823@g5.osdl.org> <20060520105547.220f2bea.akpm@osdl.org> <200605210015.15847.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dbl.q-ag.de ([213.172.117.3]:51102 "EHLO dbl.q-ag.de")
	by vger.kernel.org with ESMTP id S1751421AbWEUHN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 May 2006 03:13:28 -0400
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200605210015.15847.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:

>My NF4Pro machine now reliably does
>
>Disconnecting: Bad packet length 3742984839.
>
>when I display a lot of data through ssh.  Apparently it generates some 
>corruption that's not caught by the TCP checksum.
>
The nic does hw checksumming - thus the tcp checksum won't catch driver 
bugs.

> Would that be fixed by this
>change too? 
>
>  
>
No idea, but unlikely. The fix removes a duplicate request_irq call. Is 
it possible that the both instances run concurrently?

--
    Manfred
