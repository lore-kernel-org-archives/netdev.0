From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 6/6] ixgbe: Add malicious driver detection support
Date: Mon, 26 Jun 2017 23:26:19 -0400 (EDT)
Message-ID: <20170626.232619.984190800113889312.davem@davemloft.net>
References: <20170626213933.9635-1-jeffrey.t.kirsher@intel.com>
        <20170626213933.9635-7-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.greenwalt@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751922AbdF0D0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 23:26:22 -0400
In-Reply-To: <20170626213933.9635-7-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 26 Jun 2017 14:39:33 -0700

> +		if ((adapter->num_vfs) && (hw->mac.ops.disable_mdd) &&

Excessive parenthesis.

> +		if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&

Likewise.

> +	if ((adapter->num_vfs) && (hw->mac.ops.disable_mdd) &&

Likewise.

> +	if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&

Likewise.

> +	/* Turn on malicious driver detection */
> +	if ((adapter->num_vfs) && (hw->mac.ops.enable_mdd) &&

Likewise.

> +	/* Turn off malicious driver detection */
> +	if ((hw->mac.ops.disable_mdd) &&

Likewise.
