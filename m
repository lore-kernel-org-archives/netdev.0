From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC PATCH 34/35] Add the Xen virtual network
	device driver.
Date: Tue, 9 May 2006 13:32:59 -0700
Message-ID: <20060509203259.GT24291@moss.sous-sol.org>
References: <20060509084945.373541000@sous-sol.org>
	<20060509085201.446830000@sous-sol.org>
	<20060509132556.76deaa91@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Return-path: <xen-devel-bounces@lists.xensource.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060509132556.76deaa91@localhost.localdomain>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@osdl.org) wrote:
> > +	info->irq = bind_evtchn_to_irqhandler(
> > +		info->evtchn, netif_int, SA_SAMPLE_RANDOM,
> > netdev->name,
> 
> This doesn't look like a real random entropy source. packets
> arriving from another domain are easily timed.

Heh, given the path they take, that sadly may not be the case ;-)
But point well-taken, that's easy to drop.

thanks,
-chris
