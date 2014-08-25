From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 08/12] net: dsa: allow updating fixed PHY
 link information
Date: Mon, 25 Aug 2014 23:33:24 +0400
Message-ID: <53FB8F84.20208@cogentembedded.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-9-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:52390 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbaHYTd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:33:28 -0400
Received: by mail-la0-f51.google.com with SMTP id pn19so13857068lab.10
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:33:27 -0700 (PDT)
In-Reply-To: <1408905869-10471-9-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/24/2014 10:44 PM, Florian Fainelli wrote:

> Allow switch drivers to hook a PHY link update callback to perform
> port-specific link work.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

[...]

> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 893afe9e60aa..ee019ec29dec 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
[...]
> @@ -389,6 +401,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
>   	struct dsa_switch *ds = p->parent;
>   	struct dsa_chip_data *cd = ds->pd;
>   	struct device_node *phy_dn, *port_dn;
> +	unsigned int phy_is_fixed = 0;

    Why not *bool*?

[...]

WBR, Sergei
