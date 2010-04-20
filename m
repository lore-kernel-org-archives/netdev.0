From: Gaspar Chilingarov <gasparch@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:18:17 +0500
Message-ID: <v2n46c8cb3e1004201618s37e9f0c6j7527e59673a34322@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
	 <1271802676.7895.457.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:59603 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0DTXST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:18:19 -0400
Received: by bwz25 with SMTP id 25so7435234bwz.28
        for <netdev@vger.kernel.org>; Tue, 20 Apr 2010 16:18:17 -0700 (PDT)
In-Reply-To: <1271802676.7895.457.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Its doable, only if you bind() your sockets before connect()
>
> For each socket, you'll need to chose an (local IP, local port) not
> already in use.
>
> kernel wont magically select one source IP from the pool you have.
>

I expect that I should select source IP and kernel should find some
unused local_port for me.

I'm binding before the connect, of course ;)


-- 
Gaspar Chilingarov
