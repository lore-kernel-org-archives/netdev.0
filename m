From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Tue, 27 Jan 2009 01:30:08 -0800 (PST)
Message-ID: <115072.73028.qm@web110606.mail.gq1.yahoo.com>
References: <gkt97e$ti0$1@ger.gmane.org> <20090117194045.649f55a0@osprey.hogchain.net> <767752.95325.qm@web110601.mail.gq1.yahoo.com> <20090118095231.2c73c448@osprey.hogchain.net> <879024.62535.qm@web110609.mail.gq1.yahoo.com> <20090118115858.1b636b2d@osprey.hogchain.net> <884897.63360.qm@web110608.mail.gq1.yahoo.com> <20090125210017.04e38348@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web110606.mail.gq1.yahoo.com ([67.195.13.197]:30119 "HELO
	web110606.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751750AbZA0JaK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 04:30:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



 > From: Jay Cliburn <jcliburn@gmail.com>

> 
> On Sun, 25 Jan 2009 08:17:25 -0800 (PST)
> Sitsofe Wheeler wrote:
> 
> > OK the circumstances took a lllllong time to occur again but the result is 
> that
> > the patch does not prevent the warning. 
> 
> Can you trigger the warning by performing these steps while the interface is up?
> 
> unplug cable
> ifdown eth0
> ifup eth0
> replug cable      
> wait about 5 seconds...
> 
> If it doesn't happen the first time, try 3 or 4 more times.
> 
> Let me know what happens.

The slowpath warning never comes up with this method. I tried with the commands ifdown eth0; ifup eth0 (after removing network manager's control of the device) and ifconfig eth0 down; ifconfig eth0 up (with and without network manager) but none of the aforementioned resulted in an error.



      
