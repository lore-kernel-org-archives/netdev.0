From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: fix function kernel doc
	description
Date: Sun, 16 Mar 2014 23:15:40 -0700
Message-ID: <CAL3LdT4YpovVN+RGCPf9rp0K6GF-ap96_K2vkLyApoaecP4_ZQ@mail.gmail.com>
References: <1395006075-10919-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1395006075-10919-1-git-send-email-sakiwit@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sun, Mar 16, 2014 at 2:41 PM, Jean Sacren <sakiwit@gmail.com> wrote:
> The commit c7d05ca89f8e ("i40e: driver ethtool core") introduced the
> new function i40e_add_del_fdir_sctpv4() with the kernel doc
> description a little bit off. The trivial error was copied over to a
> different file by the commit 17a73f6b1401 ("i40e: Flow Director
> sideband accounting") most recently. Fix the kernel doc with the
> correct description for clarity.
>
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

Thanks Jean, I will add your patch to my queue.

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> index 88666adb0743..a53c4bcada79 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> @@ -299,7 +299,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
>   * @raw_packet: the pre-allocated packet buffer for FDir
>   * @add: true adds a filter, false removes it
>   *
> - * Returns 0 if the filters were successfully added or removed
> + * Always returns -EOPNOTSUPP
>   **/
>  static int i40e_add_del_fdir_sctpv4(struct i40e_vsi *vsi,
>                                     struct i40e_fdir_filter *fd_data,
>

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
