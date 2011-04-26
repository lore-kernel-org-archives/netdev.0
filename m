From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33842] New: NULL pointer dereference in
 ip_fragment
Date: Tue, 26 Apr 2011 23:24:07 +0200
Message-ID: <1303853047.2699.15.camel@edumazet-laptop>
References: <20110426203154.GM15903@stratus.com>
	 <20110426.134637.48491363.davem@davemloft.net>
	 <1303851185.2699.7.camel@edumazet-laptop>
	 <20110426205901.GN15903@stratus.com>
	 <1303851718.2699.8.camel@edumazet-laptop>
	 <20110426211946.GO15903@stratus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, tom@dbservice.com
To: Bandan Das <bandan.das@stratus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46869 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932644Ab1DZVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:24:12 -0400
Received: by wya21 with SMTP id 21so806238wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:24:11 -0700 (PDT)
In-Reply-To: <20110426211946.GO15903@stratus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 17:19 -0400, Bandan Das a =C3=A9crit :
> >=20
> Yeah, I just rechecked and this is already in Linus' tree. So, Tomas =
you can
> either try pulling in those changes or you can apply this patch and s=
ee
> if it makes any difference. Thanks!

Better pull Linus tree because there is another patch involved.

(commits c65353daf137dd41f3ede3baf62d561fca076228
ip: ip_options_compile() resilient to NULL skb route)



