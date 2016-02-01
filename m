From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] nftables: use list_for_each_entry_safe_reverse to
 traversal commit_list in nf_tables_abort
Date: Mon, 1 Feb 2016 18:47:33 +0800
Message-ID: <CADvbK_dRmfuJj2ZzueUhSgP4za8A2J1nn9eJvq1fncWsbGGuqA@mail.gmail.com>
References: <15bcb964221e1a9498e901417d020609cd5aac65.1449485287.git.lucien.xin@gmail.com>
	<20151209140330.GA1695@salvia>
	<CADvbK_dmqu4aFhQa2FVu=_RAVrSZ6qSixfGN9EM2dZ20CeQqUA@mail.gmail.com>
	<20151213214709.GA1827@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, davem <davem@davemloft.net>,
	fw@strlen.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f193.google.com ([209.85.214.193]:33626 "EHLO
	mail-ob0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088AbcBAKre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 05:47:34 -0500
In-Reply-To: <20151213214709.GA1827@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> No need to resend.
>
> Yes, we need this reverse iteration there to handle the 'delete table'
> command in the batch. This problem happens since we have
> nft_flush_table().
>
> Other callsites are artificially restriction deletion of inactive
> objects but that should be removed as we already discuss on the
> mailing list.
>
> So I'm applying this, thanks.

Hi Pablo, has this one been applied ?
