From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 08/11] net/fsl: use of_property_read_bool
Date: Fri, 05 Aug 2016 11:30:33 +0200
Message-ID: <1470389433.2977.31.camel@sipsolutions.net>
References: <1470387411-15879-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr>
	 (sfid-20160805_111640_944584_00A38E89)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470387411-15879-9-git-send-email-Julia.Lawall@lip6.fr> (sfid-20160805_111640_944584_00A38E89)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -	if (of_get_property(pdev->dev.of_node,
> -			    "little-endian", NULL))
> +	if (of_property_read_bool(pdev->dev.of_node, "little-
> endian"))
>  		priv->is_little_endian = true;
>  	else
>  		priv->is_little_endian = false;
> 

Perhaps, while changing this, that'd be better as

	priv->is_little_endian = of_property_read_bool(...);

Obviously that would've worked before, but now it'd be even easier to
understand, it seems.

johannes
