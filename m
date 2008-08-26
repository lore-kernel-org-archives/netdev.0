From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: Policy routing issue.
Date: Tue, 26 Aug 2008 09:01:40 +0200
Message-ID: <BAY103-DAV6C5E2426E366DB4823E13B2660@phx.gbl>
References: <Pine.LNX.4.58.0808251025100.15402@bolt.sonic.net>
Cc: <netdev@vger.kernel.org>
To: "bsilva" <bsilva@sonic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s24.bay0.hotmail.com ([65.54.246.96]:46407 "EHLO
	bay0-omc1-s24.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751365AbYHZHDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 03:03:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bsilva wrote:

> $ iptables -L -t mangle
> Chain OUTPUT (policy ACCEPT)
> target     prot opt source               destination
> MARK       tcp  --  anywhere             anywhere            tcp
dpt:162
> MARK set 0x1
>
> $ ip rule list
> 0: from all lookup 255
> 2000: from all fwmark 0x1 lookup 1

This is the expected behaviour.
See this bug report:

http://bugzilla.kernel.org/show_bug.cgi?id=9767

and this thread:

http://marc.info/?l=linux-netdev&m=121962119924048&w=2


