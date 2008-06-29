From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] Re: SFQ depth limit
Date: Sun, 29 Jun 2008 22:38:26 +0300
Message-ID: <200806292238.26445.denys@visp.net.lb>
References: <20080629191113.GA8817@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:59431 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762324AbYF2TiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 15:38:13 -0400
In-Reply-To: <20080629191113.GA8817@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 29 June 2008 22:11, Jarek Poplawski wrote:
> If it's with vanilla kernel something is wrong, but I couldn't
> reproduce this: probably some additianal data is needed. BTW,
> I see this "flows" number above isn't very useful, as it always
> repeats "limit". I attach a patch proposal to change this.
No it is ok, since filter is for protocol IP, ARP will not work. Thats what i found. 
Incorrect QoS settings can cause network breakage, thats it :-)

I will try to test patch ASAP on real load.

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
