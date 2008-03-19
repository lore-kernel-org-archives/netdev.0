From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] ucc_geth: Add 8 bytes to max TX frame for VLANs
Date: Wed, 19 Mar 2008 22:56:23 +0100
Message-ID: <m37ify1ipk.fsf@ursa.amorsen.dk>
References: <1205853088-30171-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60674 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S939341AbYCSV4e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 17:56:34 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jc6Gu-0007Fd-7t
	for netdev@vger.kernel.org; Wed, 19 Mar 2008 21:56:32 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 21:56:32 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 21:56:32 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> writes:

> Creating a VLAN interface on top of ucc_geth adds 4 bytes
> to the frame and the HW controller is not prepared to
> TX a frame bigger than 1518 bytes which is 4 bytes too
> small for a full VLAN frame. Also add 4 extra bytes for future
> expansion.

What about QinQ -- the 4 extra bytes handle that? If the limit can be
raised so easily, why have a static limit at all?


/Benny


