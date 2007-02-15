From: Andrew Morton <akpm@linux-foundation.org>
Subject: FC5 iptables-restore failure
Date: Thu, 15 Feb 2007 02:45:07 -0800
Message-ID: <20070215024507.8c97ee01.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:43071 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965833AbXBOKpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 05:45:15 -0500
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id l1FAj7hB008205
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 02:45:09 -0800
Received: from box (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id l1FAj7ub027267
	for <netdev@vger.kernel.org>; Thu, 15 Feb 2007 02:45:07 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've recently been noticing nasty messages come out of FC5:

sony:/home/akpm# service iptables stop
Flushing firewall rules:                                   [  OK  ]
Setting chains to policy ACCEPT: filter                    [  OK  ]
Unloading iptables modules:                                [  OK  ]
sony:/home/akpm# service iptables start
Applying iptables firewall rules: iptables-restore: line 20 failed
                                                           [FAILED]

Dunno when it started happening, but it's in mainline now.

It's a pretty stupid error message.  line 20 of what?

sony:/home/akpm# rpm -q iptables
iptables-1.3.5-1.2
