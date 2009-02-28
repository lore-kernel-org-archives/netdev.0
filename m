From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: xt_hashlimit fix
Date: Sat, 28 Feb 2009 09:22:58 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902280920260.7746@fbirervta.pbzchgretzou.qr>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <499EF222.3060507@cosmosbay.com> <alpine.LSU.2.00.0902201919390.5911@fbirervta.pbzchgretzou.qr>
 <alpine.LSU.2.00.0902280253370.20614@fbirervta.pbzchgretzou.qr> <49A8E036.5090802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:36000 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751622AbZB1IXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 03:23:03 -0500
In-Reply-To: <49A8E036.5090802@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2009-02-28 07:56, Eric Dumazet wrote:
>> commit 3e7ee1dcc808b8eec82eddfa0436f78e31d2004a
>> Author: Jan Engelhardt <jengelh@medozas.de>
>> Date:   Sat Feb 28 02:49:28 2009 +0100
>> 
>> netfilter: xtables: avoid pointer to self
>
>Seems good to me ! Thanks Jan !
>
>Reviewed-by: Eric Dumazet <dada1@cosmosbay.com>
>
>Are you sure xt_quota doesnt need some tweak, or should we not care of changes
>done in quota while temporary tables are installed (iptables -L) ?

Oh right, xt_quota.. thanks for noticing! Patch will follow.
