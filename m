From: Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Sun, 22 May 2011 18:01:31 +0200 (CEST)
Message-ID: <20110522174412.2F0C.0@paddy.troja.mff.cuni.cz>
References: <BANLkTinh0cmb0hzpVdm5XemT5NeULeAoHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Vasiliy Kulikov <segoon@openwall.com>,
	Solar Designer <solar@openwall.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kerberos2.troja.mff.cuni.cz ([195.113.28.3]:58884 "HELO
	kerberos2.troja.mff.cuni.cz" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751440Ab1EVQKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 12:10:00 -0400
In-Reply-To: <BANLkTinh0cmb0hzpVdm5XemT5NeULeAoHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011, Alexey Dobriyan wrote:

> Also, there was big discussion re exposing kernel socket pointers,
> which this file continue to do.

One late comment:

The code was intented to immitate /proc/net/udp.

As far as I can tell UDP and TCP (having checked udp.c and tcp_ipv[46].c
in the latest net-next-2.6) do not have any qualms about exposing kernel
pointers so we are a little bit holier than the pope here. :)

-- 
Pavel Kankovsky aka Peak                          / Jeremiah 9:21        \
"For death is come up into our MS Windows(tm)..." \ 21st century edition /

