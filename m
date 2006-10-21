From: "Matthieu CASTET" <castet.matthieu@free.fr>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Sat, 21 Oct 2006 21:10:19 +0000 (UTC)
Message-ID: <ehe2br$u1n$1@sea.gmane.org>
References: <1161335976.21402.11.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:17868 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1161025AbWJUVKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 17:10:30 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GbO6r-00028z-RW
	for netdev@vger.kernel.org; Sat, 21 Oct 2006 23:10:25 +0200
Received: from cac94-1-81-57-151-96.fbx.proxad.net ([81.57.151.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 23:10:25 +0200
Received: from castet.matthieu by cac94-1-81-57-151-96.fbx.proxad.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2006 23:10:25 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Oct 2006 17:19:36 +0800, Hong Liu wrote:

> ipw3945 TKIP hwcrypto only support RC4 encryption,
> so the stack needs to pre compute the michael MIC and the RC4key
> for it.
I suppose the hw doesn't do any hardware mic for the RX path.
It believe it should be also added.

