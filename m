From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] af_key: fix SADB_X_SPDDELETE response
Date: Fri, 10 Oct 2008 14:07:19 -0700 (PDT)
Message-ID: <20081010.140719.90758979.davem@davemloft.net>
References: <48EFB830.6030006@strongswan.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tobias.brunner@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45634
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759599AbYJJVHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:07:43 -0400
In-Reply-To: <48EFB830.6030006@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias.brunner@strongswan.org>
Date: Fri, 10 Oct 2008 22:16:48 +0200

> When deleting an SPD entry using SADB_X_SPDDELETE, c.data.byid is
> not initialized to zero in pfkey_spddelete(). Thus,
> key_notify_policy() responds with a PF_KEY message of type
> SADB_X_SPDDELETE2 instead of SADB_X_SPDDELETE.
>
> Signed-off-by: Tobias Brunner <tobias.brunner@strongswan.org>

Applied, thanks.
