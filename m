From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 02 Mar 2007 08:46:04 +0000
Message-ID: <C20D94CC.3237%Keir.Fraser@cl.cam.ac.uk>
References: <20070301173030.754514ec@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, Jeff Garzik <jeff@garzik.org>,
	Andi Kleen <ak@muc.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>, Zachary@smtp.osdl.org,
	virtualization@lists.osdl.org, Andrew Morton <akpm@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
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

On 2/3/07 01:30, "Stephen Hemminger" <shemminger@linux-foundation.org>
wrote:

> What about implementing the unused arp_announce flag on the inetdevice?
> Something like the following.  Totally untested...
> 
> Looks like it either was there (and got removed) or was planned but
> never implemented.

This would be acceptable. It only needs a simple script to poke the correct
value, and that could be easily integrated into vendor scripts. The general
idea of being able to have a callback to userspace is okay but we'd like
something lighter weight for live migration, which is typically done only
within the scope of a single layer-2 network and hence all that is really
required is the gratuitous ARP to kick the switch hardware.

 -- Keir
