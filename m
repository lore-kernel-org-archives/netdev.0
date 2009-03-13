From: feldmaus <feldmann_markus@gmx.de>
Subject: Re: no IPv6 Routers present
Date: Fri, 13 Mar 2009 13:22:25 +0000 (UTC)
Message-ID: <loom.20090313T131931-421@post.gmane.org>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com> <loom.20090313T082825-818@post.gmane.org> <49BA49C6.2020007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:57497 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbZCMNWy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 09:22:54 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Li7La-0003ud-S8
	for netdev@vger.kernel.org; Fri, 13 Mar 2009 13:22:47 +0000
Received: from dslb-092-076-244-077.pools.arcor-ip.net ([92.76.244.77])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 13:22:46 +0000
Received: from feldmann_markus by dslb-092-076-244-077.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 13:22:46 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich <at> hp.com> writes:

> Get rid of NOARP in you eth0 case, and it should work.
> 
It seems to better, but i do not know how the <NOARP> comes from ?

I changed my </etc/network/interfaces> from:
iface dsl-provider inet ppp
    pre-up /sbin/ifconfig eth0 up -arp 0# line maintained by pppoeconf
    provider dsl-provider

to this one:
iface dsl-provider inet ppp
    pre-up /sbin/ifconfig eth0 up # line maintained by pppoeconf
    provider dsl-provider

Should this the key ?

Regards Markus

