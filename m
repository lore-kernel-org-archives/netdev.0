From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] make e1000_dump_eeprom() static
Date: Wed, 30 Jan 2008 13:52:11 -0800
Message-ID: <47A0F18B.109@intel.com>
References: <20080130200245.GZ29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com
To: Adrian Bunk <bunk@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080130200245.GZ29368@does.not.exist>
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

Adrian Bunk wrote:
> This patch makes the needlessly global e1000_dump_eeprom() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

yes, thanks, I'll push it to Jeff.

Auke

> 
> ---
> b5fd924a1388d4aaa94cf05e42e317c2b1fb5748 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 7f5b2ae..8a6645b 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -820,7 +820,7 @@ e1000_reset(struct e1000_adapter *adapter)
>  /**
>   *  Dump the eeprom for users having checksum issues
>   **/
> -void e1000_dump_eeprom(struct e1000_adapter *adapter)
> +static void e1000_dump_eeprom(struct e1000_adapter *adapter)
>  {
>  	struct net_device *netdev = adapter->netdev;
>  	struct ethtool_eeprom eeprom;
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
