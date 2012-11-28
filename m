From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Wed, 28 Nov 2012 17:14:02 -0300
Message-ID: <50B6708A.8020701@gont.com.ar>
References: <50B4D43A.7030208@gont.com.ar> <alpine.LNX.2.01.1211271703530.8184@nerf07.vanv.qr> <50B66CA1.5050907@gont.com.ar> <alpine.LNX.2.01.1211282102240.11155@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:53701 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683Ab2K1UOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 15:14:16 -0500
In-Reply-To: <alpine.LNX.2.01.1211282102240.11155@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2012 05:06 PM, Jan Engelhardt wrote:
>> If the VPN is supposed to secure all traffic, and the VPN just fails to
>> support v6, then for me, it's questionable to have your traffic leak out
>> the VPN just because of that lack of IPv6 support.
> 
> Well, what I am saying is that a server may not
> be conveying "all", but only "0.0.0.0/0".

In such scenarios, doing nothing about IPv6 would be an oversight/error,
since IPv4 and IPv6 do not operate isolated from each other.

Cheers,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
