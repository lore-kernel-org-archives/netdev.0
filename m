From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 3/3] nftables: Convert nft_hash to use generic rhashtable
Date: Fri, 01 Aug 2014 11:17:03 +0100
Message-ID: <970429e5-2465-40f2-998b-b82dab3debe8@email.android.com>
References: <cover.1406882738.git.tgraf@suug.ch><cover.1406882738.git.tgraf@suug.ch> <ea51f2fdfb1ce84ff109d03bf37811e4b24135c5.1406882738.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	josh@joshtriplett.org, challa@noironetworks.com,
	walpole@cs.pdx.edu, dev@openvswitch.org, tklauser@distanz.ch,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54028 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaHAKRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 06:17:22 -0400
In-Reply-To: <ea51f2fdfb1ce84ff109d03bf37811e4b24135c5.1406882738.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1. August 2014 09:52:00 GMT+01:00, Thomas Graf <tgraf@suug.ch> wrote:
>If the set size is known in advance, the table is sized accordingly,
>otherwise the table size will default to 64. This is a slight change
>in behaviour as previously the default was 4 which eventually required
>many expansion iterations.

That's assuming a sufficient number of entries will be added. I think there
will be many cases in nftables where the number will be lower. Since
expansion is not very expansive this number was chosen very deliberately
and I'd prefer to keep it.

Other than that:

Acked-by: Patrick McHardy <kaber@trash.net>
