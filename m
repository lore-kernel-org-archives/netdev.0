From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/3 net-2.6.25] call FIB rule->action in the correct namespace
Date: Thu, 17 Jan 2008 11:41:36 +0100
Message-ID: <478F30E0.5090901@fr.ibm.com>
References: <478F2933.1000007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:44150 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbYAQKm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 05:42:56 -0500
Received: from d12nrmr1507.megacenter.de.ibm.com (d12nrmr1507.megacenter.de.ibm.com [9.149.167.1])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0HAgtnh333556
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 10:42:55 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1507.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0HAgs2W2310208
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 11:42:54 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0HAgsf4029953
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 11:42:54 +0100
In-Reply-To: <478F2933.1000007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> FIB rule->action should operate in the same namespace as fib_lookup.
> This is definitely missed right now.
> 
> There are two ways to implement this: pass struct net into another rules
> API call (2 levels) or place netns into rule struct directly. The second
> approach seems better as the code will grow less.
> 
> Additionally, the patchset cleanups struct net from
> fib_rules_register/unregister to have network namespace context at the
> time of default rules creation.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

-- 






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Sie`ge Social : Tour Descartes, 2, avenue Gambetta, La De'fense 5, 92400
Courbevoie
RCS Nanterre 552 118 465
Forme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
