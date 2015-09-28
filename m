From: Julian Anastasov <ja@ssi.bg>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Mon, 28 Sep 2015 22:12:35 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NETDEV <netdev@vger.kernel.org>
To: Anand Gurram <anandarao.gurram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35512 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750730AbbI1TMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 15:12:39 -0400
In-Reply-To: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 28 Sep 2015, Anand Gurram wrote:

> I am currently using kernel version 3.16.7 on a linux switch.
> While creating and destroying network namespaces I am observing below logs
> on the console
> "unregister_netdevice: waiting for lo to become free. Usage count = 1"
> 
> Can you please suggest and provide instructions on how to debug this issue.
> If any fix already available can you please point me to the link.

	There are two commits from Linux 4.2 that may help:

commit e9e4dd3267d0 ("net: do not process device backlog during unregistration")
commit 2c17d27c36dc ("net: call rcu_read_lock early in process_backlog")

	For now I see them only in 3.2.71+ and 3.12.48+.
I think, they will appear in other stable versions too...

Regards

--
Julian Anastasov <ja@ssi.bg>
