From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 18 Jun 2007 09:18:41 +0800
Message-ID: <1182129521.4092.77.camel@debian.sh.intel.com>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65203 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345AbXFRBUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2007 21:20:33 -0400
In-Reply-To: <1181904575.4102.31.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-15 at 06:49 -0400, jamal wrote:
> Hello Yi,
> 
> On Fri, 2007-15-06 at 09:27 +0800, Zhu Yi wrote:
> 
> > 1. driver becomes complicated (as it is too elaborate in the queue
> > wakeup strategies design)
> 
> I am not sure i see the complexity in the wireless driver's wakeup
> strategy. I just gave some suggestions to use management frames - they
> dont have to be literally that way.
> 
> > 2. duplicated code among drivers (otherwise you put all the queue
> > management logics in a new layer?)
> 
> There will be some shared code on drivers of same media on the
> netif_stop/wake strategy perhaps, but not related to queue management. 
> 
> > 3. it's not 100% accurate. there has to be some overhead, more or less
> > depends on the queue wakeup strategy the driver selected.
> 
> Why is it not accurate for wireless? I can see the corner case Patrick
> mentioned in wired ethernet but then wired ethernet doesnt have other
> events such as management frames (actually DCE does) to help. 

Would you respond the question I asked early, in your model how to
define the queue wakeup strategy in the driver to deal with the PHL full
situation? Consider about 1) both high prio and low prio packets could
come (you cannot predict it beforehand) 2) the time for PHL to send out
a packet to the wireless medium is relative long (given the medium is
congested). If you can resolve it in an elegant way, I'm all ears.

Thanks,
-yi
