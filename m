From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Wed, 26 May 2010 18:15:36 +0200
Message-ID: <201005261815.36512.arnd@arndb.de>
References: <C821E15E.35236%scofeldm@cisco.com> <20100526155616.GB2497@x200.localdomain> <OFB3363EDA.945755DA-ON8525772F.0057CBD1-8525772F.00589D2B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	Dirk Herrendoerfer <d.herrendoerfer@de.ibm.com>,
	netdev@vger.kernel.org, Scott Feldman <scofeldm@cisco.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vivek Kashyap <vivk@us.ibm.com>
To: Stefan Berger <stefanb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:60746 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab0EZQPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 12:15:49 -0400
In-Reply-To: <OFB3363EDA.945755DA-ON8525772F.0057CBD1-8525772F.00589D2B@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 May 2010, Stefan Berger wrote:
> I can start my dummy netlink 'server' twice and have two recipients of the 
> libvirt 
> message and thus two servers can (maliciously) respond. Well, netlink 
> doesn't
> seem to be as 'directed' as unixio. We could run the netlink type of 
> messages

libvirt can still check if the sender pid of the response is what it
thinks it should be.

	Arnd
