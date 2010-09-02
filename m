From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: arp: code cleanup
Date: Thu, 02 Sep 2010 10:27:33 +0200
Message-ID: <1283416053.2454.5.camel@edumazet-laptop>
References: <1283415511-4772-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58876 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab0IBI1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 04:27:39 -0400
Received: by wwj40 with SMTP id 40so460026wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 01:27:37 -0700 (PDT)
In-Reply-To: <1283415511-4772-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 16:18 +0800, Changli Gao a =C3=A9crit=
 :

> Replace printk(KERN_DEBUG...) with pr_debug(...).

pr_debug() is not an exact replacement of printk(KERN_DEBUG ...)

With pr_debug(), you need to recompile this file with -DDEBUG or
CONFIG_DYNAMIC_DEBUG if you want to catch the messages.

Thats the reason why Joe Perches usually doesnt touch
printk(KERN_DEBUG ...) occurrences.



