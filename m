From: "Matthieu CASTET" <castet.matthieu@free.fr>
Subject: Re: softmac mtu
Date: Mon, 25 Sep 2006 19:17:31 +0000 (UTC)
Message-ID: <ef9a0b$4jb$4@sea.gmane.org>
References: <ef3s4u$or5$3@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:48552 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751522AbWIYTUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 15:20:22 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GRvzo-0007Ea-6J
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 21:20:04 +0200
Received: from cac94-1-81-57-151-96.fbx.proxad.net ([81.57.151.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 21:20:03 +0200
Received: from castet.matthieu by cac94-1-81-57-151-96.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 21:20:03 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So why a special mtu handler is not implemented in 802.11 stack :
- 802.11 stack doesn't support bigger packet
- 802.11 stack doesn't support very bigger packet (with
802.11 fragmentation)
- 802.11 writers were lazy

Matthieu

