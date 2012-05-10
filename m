From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/14] batman-adv: split neigh_new function into
 generic and batman iv specific parts
Date: Wed, 09 May 2012 20:41:11 -0400 (EDT)
Message-ID: <20120509.204111.1931607501484626500.davem@davemloft.net>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
	<1336561976-16088-8-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	lindner_marek@yahoo.de
To: ordex@autistici.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756628Ab2EJAoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 20:44:22 -0400
In-Reply-To: <1336561976-16088-8-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>
Date: Wed,  9 May 2012 13:12:49 +0200

> From: Marek Lindner <lindner_marek@yahoo.de>
> 
> Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
> Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>

The namespace pollution of the batman-adv code needs to improve,
and I'm putting my foot down starting with this change.

If you have a static function which is therefore private to a
source file, name it whatever you want.

But once it gets exported out of that file, you have to give it
an appropriate name.  Probably with a "batman_adv_" prefix or
similar.

Otherwise, for one thing, if this code is statically built into
the tree it can conflict with symbol names elsewhere and break
the build.
