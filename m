From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCHv4 2/7] ethtool: Call ethtool's
 get/set_settings callbacks with cleaned data
Date: Thu, 28 Apr 2011 09:34:18 +0200
Message-ID: <20110428073417.GA2220@redhat.com>
References: <1303965163-8198-1-git-send-email-decot@google.com>
	<1303965163-8198-3-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: David Decotigny <decot@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1303965163-8198-3-git-send-email-decot@google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2011 at 09:32:38PM -0700, David Decotigny wrote:
> --- a/drivers/net/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/stmmac/stmmac_ethtool.c
> @@ -237,13 +237,12 @@ stmmac_set_pauseparam(struct net_device *netdev,
>  
>  	if (phy->autoneg) {
>  		if (netif_running(netdev)) {
> -			struct ethtool_cmd cmd;
> +			struct ethtool_cmd cmd = { .cmd = ETHTOOL_SSET };
>  			/* auto-negotiation automatically restarted */
> -			cmd.cmd = ETHTOOL_NWAY_RST;

Why did you change ETHTOOL_NWAY_RST to ETHTOOL_SSET ?


------------------------------------------------------------------------------
WhatsUp Gold - Download Free Network Management Software
The most intuitive, comprehensive, and cost-effective network 
management toolset available today.  Delivers lowest initial 
acquisition cost and overall TCO of any competing solution.
http://p.sf.net/sfu/whatsupgold-sd
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
