From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Mon, 12 Nov 2007 14:33:42 -0800 (PST)
Message-ID: <20071112.143342.10809862.davem@davemloft.net>
References: <47365200.0f10240a.0686.2173@mx.google.com>
	<47388988.1000506@intel.com> <47388B9F.7050308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com
To: kaber@trash.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47388B9F.7050308@trash.net>
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

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 12 Nov 2007 18:21:35 +0100

> Do you really consider that a realistic choice? Who is going to
> remove interfaces that are in use just to see traffic for other
> VLANs? Sniffing specific VLANs can always be done on the VLAN
> device itself.

Change the example to wanting to see traffic on another
physical switch.

How is this any different?

> IMO its more a question of what we want promiscous mode to mean,
> and I tend to agree with Joonwoo that it should receive all packets.

On what LAN?

When you select VLAN, you by definition are asking for non-VLAN
traffic to be elided.  It is like plugging the ethernet cable
into one switch or another.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
