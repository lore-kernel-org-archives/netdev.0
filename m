From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: Multicast packet loss
Date: Fri, 30 Jan 2009 21:17:35 +0200
Message-ID: <200901302117.35110.denys@visp.net.lb>
References: <49833DBC.7040607@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kenny Chang <kchang@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57508 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525AbZA3TRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 14:17:41 -0500
In-Reply-To: <49833DBC.7040607@athenacr.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 January 2009 19:49:48 Kenny Chang wrote:
> Hi all,
>
> We've been having some issues with multicast packet loss, we were wondering
> if anyone knows anything about the behavior we're seeing.

I didn't work much on multicast, but i have heavy unicast udp streaming (PEP 
for satellite).

First thing to check
net.core.wmem_max = 131071
net.core.wmem_default = 124928
net.ipv4.udp_mem = 379008       505344  758016

Usually they are too small by default.

next
netstat -s

Important part
Udp:
    1263992126 packets received
    260196 packets to unknown port received.
    627001 packet receive errors
    74235906 packets sent
    RcvbufErrors: 56683
    SndbufErrors: 4295851


in your case     SndbufErrors matter.
