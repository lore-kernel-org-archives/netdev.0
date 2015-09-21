From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: reinitialize pointer after skb linearize
Date: Sun, 20 Sep 2015 22:31:41 -0700 (PDT)
Message-ID: <20150920.223141.1404664230950035124.davem@davemloft.net>
References: <1442565991-4531-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbbIUFbm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:31:42 -0400
In-Reply-To: <1442565991-4531-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: <erik.hugne@ericsson.com>
Date: Fri, 18 Sep 2015 10:46:31 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
>=20
> The msg pointer into header may change after skb linearization.
> We must reinitialize it after calling skb_linearize to prevent
> operating on a freed or invalid pointer.
>=20
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Tam=E1s V=E9gh <tamas.vegh@ericsson.com>

Applied, thanks.
