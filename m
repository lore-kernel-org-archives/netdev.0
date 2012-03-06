From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Allow stmmac to work with other PHY buses(v2).
Date: Tue, 06 Mar 2012 16:57:03 -0500 (EST)
Message-ID: <20120306.165703.277843706808689044.davem@davemloft.net>
References: <1331012520-19574-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, srinivas.kandagatla@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756390Ab2CFV5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:57:09 -0500
In-Reply-To: <1331012520-19574-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue,  6 Mar 2012 06:42:00 +0100

> After commit "db8857b stmmac: use an unique MDIO bus name" and "90b9a54
> stmmac: fix phy naming inconsistency" stmmac cant work with other MDIO
> buses, because mdio_bus name is fixed in the dirver.

This sounds inaccurate, you're making it sound like these commits
introduced this limitation, as far as I can tell they did not.

Before the MDIO bus name was just plain "%x" and the bus_id number
was placed there.  Then it became the same thing, except with some
(potentially fixed) prefix.

Nothing about that change makes any difference whatsoever about
what you're modifications are trying to allow.

BTW, also, commit "90b9a54" is ambiguous.

[davem@bql net]$ git show 90b9a54
error: short SHA1 90b9a54 is ambiguous.
error: short SHA1 90b9a54 is ambiguous.
fatal: ambiguous argument '90b9a54': unknown revision or path not in the working tree.
