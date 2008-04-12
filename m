From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 3/14][TUN]: Introduce the tun_net structure.
Date: Sat, 12 Apr 2008 12:44:00 +0400
Message-ID: <48007650.7050603@openvz.org>
References: <47FE2AD4.9080609@openvz.org> <47FE2CF0.6080100@openvz.org> <20080411010142.GA16878@linux.vnet.ibm.com> <47FF198F.3070806@openvz.org> <20080411150440.GA8354@linux.vnet.ibm.com> <47FF8782.6010006@openvz.org> <20080411162752.GB29878@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49699 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756744AbYDLJbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:31:34 -0400
In-Reply-To: <20080411162752.GB29878@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So RCU is protecting -only- the net_generic structure that net_generic()
> is traversing, and the structure returned by net_generic() is protected
> by a reference counter in the upper-level struct net.
> 
> If this is the approach, I am happy.  ;-)

Yup! Thank you :)

> 							Thanx, Paul
> 

