From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Mon, 4 Sep 2017 15:10:24 +0200
Message-ID: <20170904151024.707f614e@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e@erig.me, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1504096752-102003-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2017 20:39:12 +0800, Yi Yang wrote:
> +enum ovs_nsh_key_attr {
> +	OVS_NSH_KEY_ATTR_BASE,  /* struct ovs_nsh_key_base. */
> +	OVS_NSH_KEY_ATTR_MD1,   /* struct ovs_nsh_key_md1. */
> +	OVS_NSH_KEY_ATTR_MD2,   /* variable-length octets for MD type 2. */
> +	__OVS_NSH_KEY_ATTR_MAX
> +};

One more thing: 0 is reserved, the first attr must be
OVS_NSH_KEY_ATTR_UNSPEC.

 Jiri
