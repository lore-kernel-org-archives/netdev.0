From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: micrel: ksz884x.c: Remove some unused
 functions
Date: Fri, 02 Jan 2015 16:35:58 -0500 (EST)
Message-ID: <20150102.163558.1139468085145968126.davem@davemloft.net>
References: <1420131623-30749-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, w-lkml@lebenslange-mailadresse.de,
	ebiederm@xmission.com, benoit.taine@lip6.fr, Julia.Lawall@lip6.fr,
	manuel.schoelling@gmx.de, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rickard_strandqvist@spectrumdigital.se
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420131623-30749-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Thu,  1 Jan 2015 18:00:23 +0100

> Removes some functions that are not used anywhere:
> hw_w_phy_link_md() hw_r_phy_link_md() hw_w_phy_polarity()
> hw_r_phy_polarity() hw_w_phy_crossover() hw_r_phy_crossover()
> hw_r_phy_rem_cap() hw_w_phy_auto_neg() hw_r_phy_auto_neg()
> hw_r_phy_link_stat() sw_get_addr() port_chk_prio() port_chk_replace_vid()
> port_chk_802_1p() port_chk_diffserv() sw_chk_unk_def_port()
> sw_cfg_unk_def_port() sw_cfg_chk_unk_def_deliver() sw_cfg_unk_def_deliver()
> port_chk_in_filter() port_chk_dis_non_vid() port_cfg_in_filter()
> port_cfg_dis_non_vid() port_chk_rmv_tag() port_chk_ins_tag()
> port_cfg_rmv_tag() port_cfg_ins_tag() sw_flush_dyn_mac_table() port_cfg_tx()
> port_cfg_rx() port_chk_force_flow_ctrl() port_chk_back_pressure()
> port_cfg_force_flow_ctrl() port_chk_broad_storm() hw_ena_intr_bit()
> 
> This was partially found by using a static code analysis program called cppcheck.
> 
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

This causes a cascade of new warnings because now functions like
phy_chk() are unused in some configurations.

I'm really not thrilled to even review change from you of this nature
if you aren't going to be careful about attending to details like
that.

Just blindly removing functions and not looking at the context or
other potential side effects is not really acceptable.
