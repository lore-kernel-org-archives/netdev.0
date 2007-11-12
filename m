From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Mon, 12 Nov 2007 14:54:35 -0800
Message-ID: <4738D9AB.8080408@intel.com>
References: <47365200.0f10240a.0686.2173@mx.google.com>
	<47388988.1000506@intel.com>	<47388B9F.7050308@trash.net>
	<20071112.143342.10809862.davem@davemloft.net>
	<4738D70C.4060404@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com, kaber@trash.net,
	David Miller <davem@davemloft.net>
To: Chris Friesen <cfriesen@nortel.com>
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

Chris Friesen wrote:
> David Miller wrote:
> 
>> When you select VLAN, you by definition are asking for non-VLAN
>> traffic to be elided.  It is like plugging the ethernet cable
>> into one switch or another.
> 
> For max functionality it seems like the raw eth device should show
> everything on the wire in promiscuous mode.
> 
> If we want to sniff only the traffic for a specific vlan, we can sniff
> the vlan device.

actually the impact can be quite negative, imagine doing a tcpdump on a 10gig
interface with vlan's enabled - all of a sudden you might accidentally flood the
system with a 100-fold increase in traffic and force the stack to dump all those
packets for you.

I'm still very reluctant about this patch, I think the current situation is OK for
everyone and offers everyone the possibility to do what they need, without hidden
consequences.

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
