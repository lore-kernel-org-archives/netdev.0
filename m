From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] ip6_tunnel: fix error code when tunnel exists
Date: Fri, 13 Mar 2015 15:46:53 +0100
Message-ID: <5502F85D.9050801@6wind.com>
References: <1426251537-31870-1-git-send-email-nicolas.dichtel@6wind.com> <1426254227.11398.183.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	me@pierre-cheynier.net,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:45645 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856AbbCMOq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 10:46:57 -0400
Received: by wibbs8 with SMTP id bs8so6585454wib.4
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 07:46:56 -0700 (PDT)
In-Reply-To: <1426254227.11398.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/03/2015 14:43, Eric Dumazet a =C3=A9crit :
[snip]
> These IS_ERR_OR_NULL(t) looks like defensive/lazy programming to me.
>
> A NULL pointer should not be allowed here.
>
> If t is not valid, it should be a plain error code mapping.
>
> I wish we get rid of all IS_ERR_OR_NULL() uses in networking tree,
> instead of adding plenty of them.
Ok, I agree. It was to minimize the patch.
I will rework it.
