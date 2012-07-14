From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: resurrecting tcphealth
Date: Sat, 14 Jul 2012 14:48:00 -0700
Message-ID: <20120714144800.7f8c97f6@nehalam.linuxnetplumber.net>
References: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Piotr Sawuk" <a9702387@unet.univie.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38537 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615Ab2GNVsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 17:48:19 -0400
In-Reply-To: <dee325378a2d3b7792da9640fc14905f.squirrel@webmail.univie.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maybe it would be better to use netlink info (for ss command)
rather than a /proc/net interface.
See how existing TCP values and MEMINFO are handled.
