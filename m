From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.3 released
Date: Tue, 7 Jul 2009 07:51:06 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0907070748430.31731@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: radvd-devel-l@litech.org
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:53083 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253AbZGGFu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 01:50:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A new version of radvd has been released.  This is a maintenance
release that provides minor changes and one new 'clients' feature 
which can be used to make radvd use only unicast and allow only 
specific clients instead of multicast (work by Michael Stapelberg).

Get it at: http://www.litech.org/radvd/

     *  Add a "clients" directive which can be used to specify the 
clients to which radvd will unicast RAs and ignore RSs from every 
other client. Possibly useful in gradual rollouts.
     * Work around Linux IPV6_RECVPKTINFO|IPV6_RECVHOPLIMIT renumbering 
issues with some combinations of glibc and kernel (e.g. OpenWrt and 
Freetz projects)
     * Use getifaddrs() on BSD instead of ioctl; work around unaligned 
traps on Alpha; Make NetBSD 5 compile.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
