From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] rtnetlink: reject non-IFLA_VF_PORT attributes
 inside IFLA_VF_PORTS
Date: Wed, 15 Jul 2015 15:54:13 -0700 (PDT)
Message-ID: <20150715.155413.665033325568101497.davem@davemloft.net>
References: <b6917238569c4f53d4516b71b8206e8d02e2ac21.1436736717.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	sfeldma@gmail.com, jgunthorpe@obsidianresearch.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33358 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbbGOWyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 18:54:14 -0400
In-Reply-To: <b6917238569c4f53d4516b71b8206e8d02e2ac21.1436736717.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 13 Jul 2015 00:06:02 +0200

> Similarly as in commit 4f7d2cdfdde7 ("rtnetlink: verify IFLA_VF_INFO
> attributes before passing them to driver"), we have a double nesting
> of netlink attributes, i.e. IFLA_VF_PORTS only contains IFLA_VF_PORT
> that is nested itself. While IFLA_VF_PORTS is a verified attribute
> from ifla_policy[], we only check if the IFLA_VF_PORTS container has
> IFLA_VF_PORT attributes and then pass the attribute's content itself
> via nla_parse_nested(). It would be more correct to reject inner types
> other than IFLA_VF_PORT instead of continuing parsing and also similarly
> as in commit 4f7d2cdfdde7, to check for a minimum of NLA_HDRLEN.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
