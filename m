From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2/3] ixgbe: Use __dev_uc_sync and
 __dev_uc_unsync for unicast addresses
Date: Wed, 11 Nov 2015 17:35:57 -0800
Message-ID: <20151111173557.6eb25df5@xeon-e3>
References: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
	<20151022232636.24612.12045.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34556 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbbKLBft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 20:35:49 -0500
Received: by padhx2 with SMTP id hx2so47714160pad.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 17:35:49 -0800 (PST)
In-Reply-To: <20151022232636.24612.12045.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Oct 2015 16:26:36 -0700
Alexander Duyck <aduyck@mirantis.com> wrote:

> +static int ixgbe_uc_unsync(struct net_device *netdev, const unsigned char *addr)
> +{
> +	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> +
> +	ixgbe_del_mac_filter(adapter, addr, VMDQ_P(0));
> +
> +	return 0;

Why add an internal function that always returns 0?
Rather than making it void.
