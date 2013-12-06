From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [net 5/6] drivers/net/*: Fix FSF address in file headers
Date: Fri, 6 Dec 2013 14:41:44 +0000
Message-ID: <20131206144144.GE30613@zion.uk.xensource.com>
References: <1386340128-23397-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Paul Mackerras <paulus@samba.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9352 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490Ab3LFOlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 09:41:46 -0500
Content-Disposition: inline
In-Reply-To: <1386340128-23397-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 06, 2013 at 06:28:47AM -0800, Jeff Kirsher wrote:
> Several files refer to an old address for the Free Software Foundation
> in the file header comment.  Resolve by replacing the address with
> the URL <http://www.gnu.org/licenses/> so that we do not have to keep
> updating the header comments anytime the address changes.
> 
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Veaceslav Falico <vfalico@redhat.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: Haiyang Zhang <haiyangz@microsoft.com>
> CC: "K. Y. Srinivasan" <kys@microsoft.com>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Ian Campbell <ian.campbell@citrix.com>
> CC: Wei Liu <wei.liu2@citrix.com>
> CC: Rusty Russell <rusty@rustcorp.com.au>
> CC: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/bonding/bond_alb.c    | 3 +--
>  drivers/net/bonding/bond_alb.h    | 3 +--
>  drivers/net/bonding/bond_sysfs.c  | 3 +--
>  drivers/net/hamradio/mkiss.c      | 3 +--
>  drivers/net/hyperv/hyperv_net.h   | 3 +--
>  drivers/net/hyperv/netvsc.c       | 3 +--
>  drivers/net/hyperv/netvsc_drv.c   | 3 +--
>  drivers/net/hyperv/rndis_filter.c | 3 +--
>  drivers/net/ppp/ppp_mppe.c        | 3 +--
>  drivers/net/virtio_net.c          | 3 +--
>  drivers/net/xen-netback/xenbus.c  | 3 +--
>  11 files changed, 11 insertions(+), 22 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 0287240..2250b06 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -12,8 +12,7 @@
>   * for more details.
>   *
>   * You should have received a copy of the GNU General Public License along
> - * with this program; if not, write to the Free Software Foundation, Inc.,
> - * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + * with this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * The full GNU General Public License is included in this distribution in the
>   * file called LICENSE.
> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
> index 4226044..e09dd4bf 100644
> --- a/drivers/net/bonding/bond_alb.h
> +++ b/drivers/net/bonding/bond_alb.h
> @@ -12,8 +12,7 @@
>   * for more details.
>   *
>   * You should have received a copy of the GNU General Public License along
> - * with this program; if not, write to the Free Software Foundation, Inc.,
> - * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + * with this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * The full GNU General Public License is included in this distribution in the
>   * file called LICENSE.
> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
> index abf5e10..c778a26 100644
> --- a/drivers/net/bonding/bond_sysfs.c
> +++ b/drivers/net/bonding/bond_sysfs.c
> @@ -12,8 +12,7 @@
>   * for more details.
>   *
>   * You should have received a copy of the GNU General Public License along
> - * with this program; if not, write to the Free Software Foundation, Inc.,
> - * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + * with this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * The full GNU General Public License is included in this distribution in the
>   * file called LICENSE.
> diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
> index 8e01c45..8a6c720 100644
> --- a/drivers/net/hamradio/mkiss.c
> +++ b/drivers/net/hamradio/mkiss.c
> @@ -9,8 +9,7 @@
>   *  for more details.
>   *
>   *  You should have received a copy of the GNU General Public License along
> - *  with this program; if not, write to the Free Software Foundation, Inc.,
> - *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
> + *  with this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * Copyright (C) Hans Alblas PE1AYX <hans@esrac.ele.tue.nl>
>   * Copyright (C) 2004, 05 Ralf Baechle DL5RB <ralf@linux-mips.org>
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> index e6fe0d8..a26eecb 100644
> --- a/drivers/net/hyperv/hyperv_net.h
> +++ b/drivers/net/hyperv/hyperv_net.h
> @@ -12,8 +12,7 @@
>   * more details.
>   *
>   * You should have received a copy of the GNU General Public License along with
> - * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> - * Place - Suite 330, Boston, MA 02111-1307 USA.
> + * this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * Authors:
>   *   Haiyang Zhang <haiyangz@microsoft.com>
> diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
> index 2b04804..93b485b 100644
> --- a/drivers/net/hyperv/netvsc.c
> +++ b/drivers/net/hyperv/netvsc.c
> @@ -11,8 +11,7 @@
>   * more details.
>   *
>   * You should have received a copy of the GNU General Public License along with
> - * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> - * Place - Suite 330, Boston, MA 02111-1307 USA.
> + * this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * Authors:
>   *   Haiyang Zhang <haiyangz@microsoft.com>
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 524f713..9184c82 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -11,8 +11,7 @@
>   * more details.
>   *
>   * You should have received a copy of the GNU General Public License along with
> - * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> - * Place - Suite 330, Boston, MA 02111-1307 USA.
> + * this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * Authors:
>   *   Haiyang Zhang <haiyangz@microsoft.com>
> diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
> index 0775f0a..1084e5d 100644
> --- a/drivers/net/hyperv/rndis_filter.c
> +++ b/drivers/net/hyperv/rndis_filter.c
> @@ -11,8 +11,7 @@
>   * more details.
>   *
>   * You should have received a copy of the GNU General Public License along with
> - * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
> - * Place - Suite 330, Boston, MA 02111-1307 USA.
> + * this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   * Authors:
>   *   Haiyang Zhang <haiyangz@microsoft.com>
> diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
> index 9a1849a..911b216 100644
> --- a/drivers/net/ppp/ppp_mppe.c
> +++ b/drivers/net/ppp/ppp_mppe.c
> @@ -27,8 +27,7 @@
>   *   GNU General Public License for more details.
>   *
>   *   You should have received a copy of the GNU General Public License
> - *   along with this program; if not, write to the Free Software
> - *   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *   along with this program; if not, see <http://www.gnu.org/licenses/>.
>   *
>   *
>   * Changelog:
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 916241d..5c24288 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -13,8 +13,7 @@
>   * GNU General Public License for more details.
>   *
>   * You should have received a copy of the GNU General Public License
> - * along with this program; if not, write to the Free Software
> - * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + * along with this program; if not, see <http://www.gnu.org/licenses/>.
>   */
>  //#define DEBUG
>  #include <linux/netdevice.h>
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index f035899..7a206cf 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -15,8 +15,7 @@
>   * GNU General Public License for more details.
>   *
>   * You should have received a copy of the GNU General Public License
> - * along with this program; if not, write to the Free Software
> - * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + * along with this program; if not, see <http://www.gnu.org/licenses/>.
>  */
>  
>  #include "common.h"
> -- 
> 1.8.3.1
