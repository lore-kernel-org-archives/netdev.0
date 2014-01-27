From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: stmmac: Silence PTP init errors on hw without
 PTP
Date: Sun, 26 Jan 2014 22:42:58 -0800 (PST)
Message-ID: <20140126.224258.1629277718676327575.davem@davemloft.net>
References: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaA0Gm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 01:42:58 -0500
In-Reply-To: <1390747844-25060-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Sun, 26 Jan 2014 15:50:43 +0100

> Logging a PTP error on hw which simply does not support PTP is not very
> useful. Moreover this message gets logged on every if-up, and if there is
> no cable inserted NetworkManager will re-try the ifup every 50 seconds.
> 
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Applied.
