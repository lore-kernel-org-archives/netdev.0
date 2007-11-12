From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Mon, 12 Nov 2007 14:28:45 -0800 (PST)
Message-ID: <20071112.142845.154035709.davem@davemloft.net>
References: <47365200.0f10240a.0686.2173@mx.google.com>
	<47388988.1000506@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com
To: auke-jan.h.kok@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47388988.1000506@intel.com>
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

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Mon, 12 Nov 2007 09:12:40 -0800

> Actually I think this patch removes a choice from the user.
> 
> Before this patch, the user can sniff all traffic by disabling vlans, or a
> specific vlan only by leaving vlans on when going into promisc mode.
> 
> After this patch, the user has no choice but to sniff all vlans at all times.
> 
> I don't think that that is such a good improvement.

I agree.

Look at the VLAN setting as being just like moving the
ethernet cable from one switch to another.

There is no logical difference.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
