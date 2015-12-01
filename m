From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 4/4] i40e: handle per queue rx_usecs setting
Date: Tue, 1 Dec 2015 11:47:26 -0800
Message-ID: <20151201114726.43d0540c@xeon-e3>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
	<1448956892-15509-4-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	davem@davemloft.net, jesse.brandeburg@intel.com,
	andi@firstfloor.org, jeffrey.t.kirsher@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	john.r.fastabend@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	f.fainelli@gmail.com, dsahern@gmail.com, tj@kernel.org,
	cascardo@redhat.com, corbet@lwn.net
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36791 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbbLATrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 14:47:18 -0500
Received: by pacdm15 with SMTP id dm15so14687355pac.3
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 11:47:18 -0800 (PST)
In-Reply-To: <1448956892-15509-4-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Dec 2015 08:01:32 +0000
kan.liang@intel.com wrote:

> +u32 i40e_ndo_get_per_queue_rx_usecs(struct net_device *dev, int index)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(dev);
> +	struct i40e_vsi *vsi = np->vsi;
> +	struct i40e_pf *pf = vsi->back;
> +	struct i40e_hw *hw = &pf->hw;
> +	u32 val;
> +
> +	val = rd32(hw, I40E_PFINT_ITRN(0, index));
> +
> +	return (val * 2);

Please don't put useless paren's around return value.
That is a BSD style that is not practiced in Linux.
