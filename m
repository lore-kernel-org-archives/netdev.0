From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 01/10] qed: Add module with basic common
 support
Date: Wed, 14 Oct 2015 18:52:30 -0700 (PDT)
Message-ID: <20151014.185230.1156225531234470619.davem@davemloft.net>
References: <1444803854-1319-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1444803854-1319-2-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754332AbbJOBgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 21:36:24 -0400
In-Reply-To: <1444803854-1319-2-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 14 Oct 2015 09:24:05 +0300

> +int qed_qm_pf_rt_init(struct qed_hwfn			*p_hwfn,
> +		      struct qed_ptt			*p_ptt,
> +		      u8				port_id,
> +		      u8				pf_id,
> +		      u8				max_phys_tcs_per_port,
> +		      bool				is_first_pf,
> +		      u32				num_pf_cids,
> +		      u32				num_vf_cids,
> +		      u32				num_tids,
> +		      u16				start_pq,
> +		      u16				num_pf_pqs,
> +		      u16				num_vf_pqs,
> +		      u8				start_vport,
> +		      u8				num_vports,
> +		      u8				pf_wfq,
> +		      u32				pf_rl,
> +		      struct init_qm_pq_params		*pq_params,
> +		      struct init_qm_vport_params	*vport_params);

Sorry, this is completely rediculous.

No function should have so many parameters.

If you need to pass this much information to a function, create a structure in
which to contain the values and pass a reference to that.
