From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 2/2] eHEA: Receive SKB Aggregation, generic LRO helper functions
Date: Thu, 5 Jul 2007 19:45:35 +0400
Message-ID: <20070705154534.GA7285@2ka.mipt.ru>
References: <200707050926.30468.ossthema@de.ibm.com> <20070705082056.GA358@2ka.mipt.ru> <200707051624.46887.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Christoph Hellwig <hch@infradead.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760084AbXGEPqU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200707051624.46887.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 04:24:46PM +0200, Jan-Bernd Themann (ossthema@de.ibm.com) wrote:
> > I've couple of comments on the driver, but mainly the fact of decreased
> > CPU usage itself - what was the magnitude of the win with this driver,
> > it looks like because of per-packet receive code path invocation is the
> > place of the latency...
> > Your implementation looks generic enough to be used by any driver, don't
> > you want to push it separately from eHEA driver?
> > 
> 
> We can try to come up with a generic file with these helperfunctions.
> What do you think about putting them into /net/ipv4/inet_lro.c and 
> /include/linux/inet_lro.h ?

The more I think, the more it looks as appropriate to be used by all hardware
drivers with proper API. As far as I recall this is third implementation
in the linux drivers :)

-- 
	Evgeniy Polyakov
