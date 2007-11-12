From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Mon, 12 Nov 2007 14:57:16 -0800 (PST)
Message-ID: <20071112.145716.06352378.davem@davemloft.net>
References: <47388B9F.7050308@trash.net>
	<20071112.143342.10809862.davem@davemloft.net>
	<4738D70C.4060404@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com, kaber@trash.net
To: cfriesen@nortel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4738D70C.4060404@nortel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Mon, 12 Nov 2007 16:43:24 -0600

> David Miller wrote:
> 
> > When you select VLAN, you by definition are asking for non-VLAN
> > traffic to be elided.  It is like plugging the ethernet cable
> > into one switch or another.
> 
> For max functionality it seems like the raw eth device should show 
> everything on the wire in promiscuous mode.
> 
> If we want to sniff only the traffic for a specific vlan, we can sniff 
> the vlan device.

VLAN settings are a filter of sorts, much like plugging into
one switch or another filters traffic physically.

If you don't want that filter, turn the VLAN settings off.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
