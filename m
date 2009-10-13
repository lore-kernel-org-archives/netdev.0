From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: behaviour question for igb on nehalem box
Date: Tue, 13 Oct 2009 11:32:43 -0600
Message-ID: <4AD4B9BB.3010209@nortel.com>
References: <4ACF8466.5030309@nortel.com>	<alpine.WNT.2.00.0910091250440.5328@jbrandeb-desk1.amr.corp.intel.com>	<4ACFB9DF.9080909@nortel.com>
	<4ACFC52F.4050509@intel.com> <4ACFCBE8.7060108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-list <e1000-devel@lists.sourceforge.net>,
	Linux Network Development list <netdev@vger.kernel.org>, "Allan,
	Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4ACFCBE8.7060108@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 10/09/2009 05:48 PM, Alexander Duyck wrote:

> The odds of any 2 flows overlapping when you are only using 4 flows is 
> pretty high, especially if the addresses/ports are close in range.  You 
> typically need something on the order of about 16 flows over a wide 
> range of port numbers in order to get a good distribution.

Yes, I realize this.  However, I was surprised that we were seeing the
packet count increasing for only one queue but the interrupt count
increasing for more than one.

Also, if we really crank up the traffic levels the box apparently
panics.  They're working on getting a serial cable hooked up to it to
get the debug information, so I don't really have much information on
that part just yet.

We're going to try the out-of-tree drivers.  Unfortunately it appears
that the out-of-tree igb driver doesn't compile for this kernel.  I
suspect the compat code needs tweaking.

Chris

------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
