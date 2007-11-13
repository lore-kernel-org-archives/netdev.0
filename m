From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Tue, 13 Nov 2007 03:36:11 -0800 (PST)
Message-ID: <20071113.033611.73195922.davem@davemloft.net>
References: <47397AB3.90705@trash.net>
	<E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com, w@1wt.eu,
	cfriesen@nortel.com, kaber@trash.net
To: herbert@gondor.apana.org.au
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 13 Nov 2007 19:09:23 +0800

> I agree.  People doing a tcpdump don't have to turn on promiscuous
> mode, that's what the -p option is for.  In other words, having
> promiscuous mode disable VLAN filtering does not take away the
> user's options at all.
> 
> In fact, the very definition of promiscuous is to turn off hardware
> filtering, albeit the filtering of MAC addresses rather than VLAN
> tags.  So it would seem logical to have it turn off VLAN filtering
> too.

Ok.

The performance implications can be pretty severe however.
I wish we could address this somehow.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
