From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i40e: don't truncate match_method assignment
Date: Sat, 10 Dec 2016 23:32:18 -0500 (EST)
Message-ID: <20161210.233218.618766359427126949.davem@davemloft.net>
References: <20161209213921.26451-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org, sfr@canb.auug.org.au,
        bimmy.pujari@intel.com
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33002 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753107AbcLKEcU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 23:32:20 -0500
In-Reply-To: <20161209213921.26451-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>
Date: Fri,  9 Dec 2016 13:39:21 -0800

> The .match_method field is a u8, so we shouldn't be casting to a u16,
> and because it is only one byte, we do not need to byte swap anything.
> Just assign the value directly. This avoids issues on Big Endian
> architectures which would have byte swapped and then incorrectly
> truncated the value.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>

Applied.
