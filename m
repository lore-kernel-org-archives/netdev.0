From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ematch: Fix auto-loading of ematch modules.
Date: Fri, 20 Feb 2015 15:31:28 -0500 (EST)
Message-ID: <20150220.153128.306170104581128825.davem@davemloft.net>
References: <CAHA+R7Os10B8KuBV0K9qp48zo2+=_aXUR-k5ocXjEWYqtq222w@mail.gmail.com>
	<20150217191520.GA15405@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ignacy.gawedzki@green-communications.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbbBTUba convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:31:30 -0500
In-Reply-To: <20150217191520.GA15405@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.fr>
Date: Tue, 17 Feb 2015 20:15:20 +0100

> In tcf_em_validate(), after calling request_module() to load the
> kind-specific module, set em->ops to NULL before returning -EAGAIN, s=
o
> that module_put() is not called again by tcf_em_tree_destroy().
>=20
> Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communication=
s.fr>

Applied and queued up for -stable, thanks.
