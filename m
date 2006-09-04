From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [2.6.19 PATCH 1/7] ehea: interface to network stack
Date: Mon, 4 Sep 2006 23:49:45 +0200
Message-ID: <20060904214945.GA30804@electric-eye.fr.zoreil.com>
References: <200609041237.46528.ossthema@de.ibm.com> <20060904201606.GA24386@electric-eye.fr.zoreil.com> <200609042311.21202.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:62175 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965005AbWIDVw1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 17:52:27 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200609042311.21202.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> :
[...]
> The driver should get merged as a single commit anyway, even
> if split diffs are posted for review. Even if it gets merged
> like this, bisect will work since the Kconfig option is added
> in the final patch.

I have seen/done worse but it's not exactly pretty.

[...]
> > > +?????int i;
> >
> > unsigned int ?
> 
> does it matter? int as a counter is pretty standard.

ppc64 takes unsigned int as a little optimization. I do not know how
the target platform behaves here.

-- 
Ueimor
