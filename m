From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Tue, 27 Nov 2012 08:04:12 -0800
Message-ID: <1354032252.14302.37.camel@edumazet-glaptop>
References: <50B4D43A.7030208@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:63214 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514Ab2K0QEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 11:04:15 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so9065233iay.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 08:04:14 -0800 (PST)
In-Reply-To: <50B4D43A.7030208@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 11:54 -0300, Fernando Gont wrote:
> Folks,
> 
> FYI. This is might affect Linux users employing e.g. OpenVPN:
> <http://tools.ietf.org/html/draft-gont-opsec-vpn-leakages>.
> 
> For a project such as OpenVPN, a (portable) fix might be non-trivial.
> However, I guess Linux might hook some iptables rules when establishing
> the VPN tunnel, such that e.g. all v6 traffic is filtered (yes, this is
> certainly not the most desirable fix, but still probably better than
> having your supposedly-secured traffic being sent in the clear).
> 
> P.S.: Not sure if this is the right list to send this note. Please
> advice of a more appropriate one and/or feel free to forward this note
> if deemed appropriate...

This seems a user space issue to me.

accept_ra on linux is set to 1, meaning that as soon as forwarding is
enabled, RA are ignored.
