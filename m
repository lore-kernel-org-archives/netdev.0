From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Wed, 28 Nov 2012 22:37:05 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211282203310.11510@nerf07.vanv.qr>
References: <50B4D43A.7030208@gont.com.ar> <alpine.LNX.2.01.1211271703530.8184@nerf07.vanv.qr> <50B66CA1.5050907@gont.com.ar> <alpine.LNX.2.01.1211282102240.11155@nerf07.vanv.qr> <50B6708A.8020701@gont.com.ar>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:57786 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932609Ab2K1VhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 16:37:06 -0500
In-Reply-To: <50B6708A.8020701@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2012-11-28 21:14, Fernando Gont wrote:

>On 11/28/2012 05:06 PM, Jan Engelhardt wrote:
>>> If the VPN is supposed to secure all traffic, and the VPN just fails to
>>> support v6, then for me, it's questionable to have your traffic leak out
>>> the VPN just because of that lack of IPv6 support.
>> 
>> Well, what I am saying is that a server may not
>> be conveying "all", but only "0.0.0.0/0"[0/0].
>
>In such scenarios, doing nothing about IPv6 would be an oversight/error,

Without additional input from the user, e.g. by means of a config 
setting, the software itself cannot distinguish between an 
oversight/error and a deliberate configuration.
