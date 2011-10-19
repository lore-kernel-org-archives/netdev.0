From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Wed, 19 Oct 2011 07:47:11 +0200
Message-ID: <1319003231.16303.2.camel@edumazet-laptop>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
		 <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		 <4E9E2929.7070701@cn.fujitsu.com>
	 <1318996187.19139.8.camel@edumazet-laptop>
	 <4E9E5E1C.5020603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46477 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab1JSFrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 01:47:19 -0400
Received: by wwe6 with SMTP id 6so1979561wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 22:47:18 -0700 (PDT)
In-Reply-To: <4E9E5E1C.5020603@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 13:20 +0800, Gao feng a =C3=A9crit :

> In orig ip_rt_frag_need,
> zero can be return only when pmtu(get from icmp packet) is zero and p=
eer is NULL.
> in this case,raw_icmp_error will not be call too.this is valid??

I dont know, tell me.

I am afraid you're adding a possible regression here.

pmtu from icmp_packet is not zero in the common case.
