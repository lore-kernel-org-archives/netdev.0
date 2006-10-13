From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Hardware bug or kernel bug?
Date: Fri, 13 Oct 2006 18:11:51 +0100
Message-ID: <1160759511.25218.65.camel@localhost.localdomain>
References: <20061013085605.GA1690@ff.dom.local>
	 <200610131256.54546.dj@david-web.co.uk>
	 <20061013130648.GC1690@ff.dom.local>
	 <200610131724.40631.dj@david-web.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:5802 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1751352AbWJMQpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 12:45:19 -0400
To: David Johnson <dj@david-web.co.uk>
In-Reply-To: <200610131724.40631.dj@david-web.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Gwe, 2006-10-13 am 17:24 +0100, ysgrifennodd David Johnson:
> IDE controller, then continuing. Could the same thing be happening in Linux? 
> If Linux can't talk to the IDE controller when trying to write to disk, how 
> does it handle that?

It will timeout and then retry the command. It's not the most ideal
situation to end up in but I'd expect to see a DMA timeout and a retry
or two in the log not a crash.

