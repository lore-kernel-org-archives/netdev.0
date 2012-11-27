From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Tue, 27 Nov 2012 17:10:20 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211271703530.8184@nerf07.vanv.qr>
References: <50B4D43A.7030208@gont.com.ar>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:51965 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514Ab2K0QKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 11:10:21 -0500
In-Reply-To: <50B4D43A.7030208@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 2012-11-27 15:54, Fernando Gont wrote:

>Folks,
>
>FYI. This is might affect Linux users employing e.g. OpenVPN:
><http://tools.ietf.org/html/draft-gont-opsec-vpn-leakages>.
>
>For a project such as OpenVPN, a (portable) fix might be non-trivial.

If the VPN server does not even advertise to-be-secured IPv6 prefixes, 
any client-side fix is questionable. Disabling all of IPv6 on the client 
just because no IPv6 prefixes were sent is bogus.. it is like disabling 
all my IPv4 internet just because the server only gave me one IPv6 route 
into $internal_company_network.
