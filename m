From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Kernel-3.1.0] mdio-gpio: Add reset functionality to
 mdio-gpio driver.
Date: Mon, 14 Nov 2011 14:42:22 -0500 (EST)
Message-ID: <20111114.144222.2216968580935980384.davem@davemloft.net>
References: <1320845931-25782-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stuart.menefy@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57939 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305Ab1KNTma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 14:42:30 -0500
In-Reply-To: <1320845931-25782-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Wed,  9 Nov 2011 13:38:51 +0000

> +	mdio_gpio_ops.reset = pdata->reset;

What if I have multiple types of devices backing a mdio_gpio, each using
different reset operations?

You can't write this variable method into a globally used set of ops.
