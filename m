From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v7 net-next 4/5] ixgbe: Add support for
	ndo_ll_poll
Date: Fri, 31 May 2013 11:32:09 +0800
Message-ID: <CAM_iQpWXuSwnRKeQYdi0bNVMMOvT=VEzF6jbHNHPa+VoUaUapA@mail.gmail.com>
References: <20130530114045.12653.79183.stgit@ladj378.jer.intel.com>
	<20130530114132.12653.19059.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, LKML <linux-kernel@vger.kernel.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <erdnetdev@gmail.com>, Eilon Greenstien <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130530114132.12653.19059.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, May 30, 2013 at 7:41 PM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
....
> +#else /* CONFIG_NET_LL_RX_POLL */
> +static inline void ixgbe_qv_init_lock(struct ixgbe_q_vector *q_vector)
> +{
> +}
> +
> +static inline int ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
> +{
> +       return true;
> +}
> +
> +static inline int ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
> +{
> +       return false;
> +}
> +
> +static inline int ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
> +{
> +       return false;
> +}
> +
> +static inline int ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
> +{
> +       return false;
> +}
> +
> +static inline int ixgbe_qv_ll_polling(struct ixgbe_q_vector *q_vector)
> +{
> +       return false;
> +}


Then please make them bool.

------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite
It's a free troubleshooting tool designed for production
Get down to code-level detail for bottlenecks, with <2% overhead.
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
