From: feldmaus <feldmann_markus@gmx.de>
Subject: Re: no IPv6 Routers present
Date: Fri, 13 Mar 2009 08:12:22 +0000 (UTC)
Message-ID: <loom.20090313T081029-473@post.gmane.org>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com> <loom.20090312T232059-421@post.gmane.org> <loom.20090313T072943-940@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55245 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757938AbZCMIMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 04:12:47 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Li2VZ-0000oX-MO
	for netdev@vger.kernel.org; Fri, 13 Mar 2009 08:12:45 +0000
Received: from dslb-092-076-249-072.pools.arcor-ip.net ([92.76.249.72])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 08:12:45 +0000
Received: from feldmann_markus by dslb-092-076-249-072.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 08:12:45 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found the Bug.

There was no rule for my chain <lan-in> and <lan-out>,
because i inserted the rule at the wrong place !
###########################################################
iptables -I lan-in 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -j ACCEPT
iptables -I lan-out 2 -s 0.0.0.0/0 -d 0.0.0.0/0 -j ACCEPT
###########################################################

It should be inserted at line 1.

Regards Markus

