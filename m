From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: unfold two loops in ip6_packet_match()
Date: Thu, 19 Feb 2009 11:19:18 +0100
Message-ID: <499D3226.6040108@trash.net>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net> <499C3871.4030600@cosmosbay.com> <499C4739.3000800@cosmosbay.com> <499C4FEB.7040706@trash.net> <499D118B.1040309@cosmosbay.com> <499D14D6.7020005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46046 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397AbZBSKTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 05:19:20 -0500
In-Reply-To: <499D14D6.7020005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> ip6_tables netfilter module can use an ifname_compare() helper
> so that two loops are unfolded.

Also applied, thanks Eric.

Are you going to send a new patch for ip_tables.c or should I
just take the old one?
