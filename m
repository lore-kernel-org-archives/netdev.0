From: "Esben Haabendal" <eha@doredevelopment.dk>
Subject: RE: [PATCH 6/9] fs_enet: Be an of_platform device
	when	CONFIG_PPC_CPM_NEW_BINDING is set.
Date: Tue, 2 Oct 2007 09:10:05 +0200
Message-ID: <003601c804c3$4556f640$d004e2c0$@dk>
References: <20070920220043.GA28769@loki.buserror.net>
	<20070920220121.GF28784@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: "'Scott Wood'" <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070920220121.GF28784@loki.buserror.net>
Content-Language: da
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi Scott,

A minor error handling bug

> +	const u32 *data = of_get_property(np, "phy-handle", &len);
> +	if (!data || len != 4)
> +		return -EINVAL;
> +
> +	phynode = of_find_node_by_phandle(*data);
> +	if (!phynode)
> +		return -EINVAL;
> +
> +	mdionode = of_get_parent(phynode);
> +	if (!phynode)

if (!mdionode)

> +		goto out_put_phy;

Best regards,
Esben
