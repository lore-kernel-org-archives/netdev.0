From: Vijay Katoch <katoch.vijay@gmail.com>
Subject: Re: PHYless ethernet switch MAC-MAC serdes connection
Date: Fri, 23 Jan 2015 16:49:36 +0000 (UTC)
Message-ID: <loom.20150123T174631-951@post.gmane.org>
References: <loom.20150120T140914-531@post.gmane.org> <54BE9B0B.7070507@gmail.com> <loom.20150121T075010-767@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56069 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbbAWQto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jan 2015 11:49:44 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1YEhQT-0004yT-RK
	for netdev@vger.kernel.org; Fri, 23 Jan 2015 17:49:42 +0100
Received: from 2024ob.scansafe.net ([115.111.223.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 17:49:41 +0100
Received: from katoch.vijay by 2024ob.scansafe.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 17:49:41 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems this behaviour is normal when assigning ip address to 3 devices 
and all of them are 'up'.
When I examined packets using wireshark, correct packets are received on 
other host.
I resolved the issue of interface that is configured first controlling 
transmission, by running ifplugd daemon. So if cable connected to port 
which was configured first is unplugged, that interface will go down, 
allowing any of the other to transmit.
