From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 2 Mar 2007 10:08:04 -0800
Message-ID: <20070302180804.GH10574@sequoia.sous-sol.org>
References: <20070301232443.195603797@goop.org>
	<20070301232529.648076372@goop.org>
	<20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zachary Amsden <zach@vmware.com>, Jeremy Fitzhardinge <jeremy@goop.org>,
	xen-devel@lists.xensource.com, Jeff Garzik <jeff@garzik.org>,
	Ian Pratt <ian.pratt@xensource.com>, Andi Kleen <ak@muc.de>,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
	virtualization@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
Content-Disposition: inline
In-Reply-To: <20070301173030.754514ec@freekitty>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

* Stephen Hemminger (shemminger@linux-foundation.org) wrote:
> +	case NETDEV_CHANGEADDR:
> +		/* Send gratuitous ARP in case of address change or new device */
> +		if (IN_DEV_ARP_ANNOUNCE(in_dev))

Conceptually right on, but it looks like improper hijacking
of arp_announce sysctl.  Could introduce another

thanks,
-chris
