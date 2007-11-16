From: Patrick McHardy <kaber@trash.net>
Subject: Re: FW: [PATCH 2/2] [e1000 VLAN] Disable vlan hw
 accel when promiscuous mode
Date: Fri, 16 Nov 2007 15:46:26 +0100
Message-ID: <473DAD42.60603@trash.net>
References: <006601c82846$b0f99eb0$9c94fea9@jason>
	<20071116143348.GA10596@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Kok, Auke'" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, Joonwoo Park <joonwpark81@gmail.com>,
	'David Miller' <davem@davemloft.net>, cfriesen@nortel.com,
	greearb@candelatech.com, w@1wt.eu
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20071116143348.GA10596@gondor.apana.org.au>
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

Herbert Xu wrote:
> BTW, how does the VLAN TX acceleration work at all? It's using
> skb->cb to carry the tags but then calls dev_queue_xmit.  Once
> you do that packet schedulers can scribble all over skb->cb.
> 
> Also vlan_skb_recv should be moved out-of-line.  It's absolutely
> humongous.  It'll generate tail-calls anyway so performance-wise
> it's useless.


I have a number of VLAN cleanups queued and intend to do these
two changes on top.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
