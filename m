From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Wed, 28 Nov 2012 21:06:12 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211282102240.11155@nerf07.vanv.qr>
References: <50B4D43A.7030208@gont.com.ar> <alpine.LNX.2.01.1211271703530.8184@nerf07.vanv.qr> <50B66CA1.5050907@gont.com.ar>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:57514 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110Ab2K1UGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 15:06:16 -0500
In-Reply-To: <50B66CA1.5050907@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2012-11-28 20:57, Fernando Gont wrote:

>On 11/27/2012 01:10 PM, Jan Engelhardt wrote:
>>> For a project such as OpenVPN, a (portable) fix might be non-trivial.
>> 
>> If the VPN server does not even advertise to-be-secured IPv6 prefixes, 
>> any client-side fix is questionable. 
>
>If the VPN is supposed to secure all traffic, and the VPN just fails to
>support v6, then for me, it's questionable to have your traffic leak out
>the VPN just because of that lack of IPv6 support.

Well, what I am saying is that a server may not
be conveying "all", but only "0.0.0.0/0".
