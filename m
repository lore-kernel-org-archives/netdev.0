From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 1/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Wed, 25 Jan 2012 14:12:37 +0100
Message-ID: <1327497157.2425.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1327494389.24561.316.camel@zakaz.uk.xensource.com>
	 <1327494434-21566-1-git-send-email-ian.campbell@citrix.com>
	 <1327495879.2425.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1327496953.24561.323.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56136 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab2AYNMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 08:12:41 -0500
Received: by wgbed3 with SMTP id ed3so5247025wgb.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 05:12:40 -0800 (PST)
In-Reply-To: <1327496953.24561.323.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 13:09 +0000, Ian Campbell a =C3=A9cr=
it :

> Can you elaborate on the specific benchmark you used there?

One machine was sending udp frames on my target (using pktgen)

Target was running a mono threaded udp receiver (one socket)
