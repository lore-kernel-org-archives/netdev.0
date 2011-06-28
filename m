From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/19] e1000e: remove unnecessary reads of
 PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 21:41:08 -0700 (PDT)
Message-ID: <20110627.214108.82245235472218188.davem@davemloft.net>
References: <1309196627-15969-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1309196627-15969-1-git-send-email-jdmason@kudzu.us>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@kudzu.us>
Date: Mon, 27 Jun 2011 12:43:47 -0500

> The PCIE capability offset is saved during PCI bus walking.  It will
> remove an unnecessary search in the PCI configuration space if this
> value is referenced instead of reacquiring it.
> 
> Signed-off-by: Jon Mason <jdmason@kudzu.us>

Applied.

------------------------------------------------------------------------------
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security 
threats, fraudulent activity, and more. Splunk takes this data and makes 
sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
