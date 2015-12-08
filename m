From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH v3 2/4] i40e: geneve tunnel offload support
Date: Tue, 8 Dec 2015 13:22:40 -0500
Message-ID: <20151208182239.GF3598@tuxdriver.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
 <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.org,
	Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57675 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbLHSaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:30:24 -0500
Content-Disposition: inline
In-Reply-To: <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:12:12AM -0800, Anjali Singhai Jain wrote:
> This patch adds driver hooks to implement ndo_ops to add/del
> udp port in the HW to identify GENEVE tunnels.
> 
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>

> @@ -10406,6 +10508,9 @@ static void i40e_print_features(struct i40e_pf *pf)
>  #if IS_ENABLED(CONFIG_VXLAN)
>  	i += snprintf(&buf[i], REMAIN(i), " VxLAN");
>  #endif
> +#if IS_ENABLED(CONFIG_GENEVE)
> +	i += snprintf(&buf[i], REMAIN(i), "Geneve ");
> +#endif
>  	if (pf->flags & I40E_FLAG_PTP)
>  		i += snprintf(&buf[i], REMAIN(i), " PTP");
>  #ifdef I40E_FCOE

It seems like it should be " Geneve" rather than "Geneve "?

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
