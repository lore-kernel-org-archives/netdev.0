From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: stmmac: use phydev from struct net_device
Date: Wed, 12 Oct 2016 01:41:28 -0400 (EDT)
Message-ID: <20161012.014128.1745551943611431590.davem@davemloft.net>
References: <1475476100-28219-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752835AbcJLFlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 01:41:32 -0400
In-Reply-To: <1475476100-28219-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Mon,  3 Oct 2016 08:28:19 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
