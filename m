From: Chris Wright <chrisw@redhat.com>
Subject: Re: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Wed, 26 May 2010 08:56:16 -0700
Message-ID: <20100526155616.GB2497@x200.localdomain>
References: <C821E15E.35236%scofeldm@cisco.com>
 <201005261438.07004.arnd@arndb.de>
 <OFCF88A167.122DD206-ON8525772F.00470999-8525772F.0047F4A5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Chris Wright <chrisw@redhat.com>,
	Dirk Herrendoerfer <d.herrendoerfer@de.ibm.com>,
	netdev@vger.kernel.org, Scott Feldman <scofeldm@cisco.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Vivek Kashyap <vivk@us.ibm.com>
To: Stefan Berger <stefanb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab0EZP5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 11:57:22 -0400
Content-Disposition: inline
In-Reply-To: <OFCF88A167.122DD206-ON8525772F.00470999-8525772F.0047F4A5@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stefan Berger (stefanb@us.ibm.com) wrote:
> When I have libvirt talk to my dummy server, I pass the getpid() of
> libvirt into the request message, just to fulfill the requirement of it
> being != 0 so the kernel driver doesn't process the msg. I also don't
> want to have to determine the pid of the target process. Now I believe
> the problem with that *may* be that multiple daemons may want to process
> the message,

What other daemon do you expect to be listening besides lldpad?

thanks,
-chris
