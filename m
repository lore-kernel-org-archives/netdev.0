From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Tue, 20 Nov 2007 14:26:48 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0711201425530.32378@fbirervta.pbzchgretzou.qr>
References: <11955644701165-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:52474 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755660AbXKTN0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 08:26:49 -0500
In-Reply-To: <11955644701165-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 20 2007 14:14, Laszlo Attila Toth wrote:
>
>This is the 6th version of our interface group patches.
>
>The interface group value can be used to manage different interfaces
>at the same time such as in netfilter/iptables.

I take it you could not use...?
	iptables -i iif1 -j dosomething
	iptables -i iif2 -j dosomething

>The netfilter patch
>is ready but future plan is the same for ip/tc commands (except
>the ifgroup value change which happens via "ip link set" command).

How can it be useful in conjunction with tc?

