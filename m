From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of/mdio: Staticise !CONFIG_OF stubs
Date: Wed, 10 Oct 2012 22:34:27 -0400 (EDT)
Message-ID: <20121010.223427.1187011104173761756.davem@davemloft.net>
References: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srinivas.kandagatla@st.com, fengguang.wu@intel.com,
	netdev@vger.kernel.org
To: broonie@opensource.wolfsonmicro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094Ab2JKCe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:34:28 -0400
In-Reply-To: <1349843618-11209-1-git-send-email-broonie@opensource.wolfsonmicro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Date: Wed, 10 Oct 2012 13:33:38 +0900

> The !CONFIG_OF stubs aren't static so if multiple files include the
> header with this configuration then the linker will see multiple
> definitions of the stubs.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Mark Brown <broonie@opensource.wolfsonmicro.com>

Applied.
