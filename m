From: Fernando Gont <fernando@gont.com.ar>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Wed, 28 Nov 2012 23:29:57 -0300
Message-ID: <50B6C8A5.2090404@gont.com.ar>
References: <50B4D43A.7030208@gont.com.ar> <alpine.LNX.2.01.1211271703530.8184@nerf07.vanv.qr> <50B66CA1.5050907@gont.com.ar> <alpine.LNX.2.01.1211282102240.11155@nerf07.vanv.qr> <50B6708A.8020701@gont.com.ar> <alpine.LNX.2.01.1211282203310.11510@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:55050 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755310Ab2K2CrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 21:47:20 -0500
In-Reply-To: <alpine.LNX.2.01.1211282203310.11510@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2012 06:37 PM, Jan Engelhardt wrote:
>> On 11/28/2012 05:06 PM, Jan Engelhardt wrote:
>>>> If the VPN is supposed to secure all traffic, and the VPN just fails to
>>>> support v6, then for me, it's questionable to have your traffic leak out
>>>> the VPN just because of that lack of IPv6 support.
>>>
>>> Well, what I am saying is that a server may not
>>> be conveying "all", but only "0.0.0.0/0"[0/0].
>>
>> In such scenarios, doing nothing about IPv6 would be an oversight/error,
> 
> Without additional input from the user, e.g. by means of a config 
> setting, the software itself cannot distinguish between an 
> oversight/error and a deliberate configuration.

Exactly. So fail on the safe side, and disable IPv6. Most users
forwarding all IPv4 traffic are meaning to secure all their traffic with
the VPN.

If you do nothing about v6, then it just takes a local attacker to
trigger v6 connectivity (or the user to connect to a dual-stacked
network) for the supposedly-secure traffic to go out in the clear.

Many people don't realize that v6 and v4, while being to different
protocols, are sticked together by means of the DNS. And the
aforementioned issue will come up as a surprise in most scenario.

Not to mention that nowadays, you will miss virtually nothing on the
Internet by having v6 off.

Thanks,
-- 
Fernando Gont
e-mail: fernando@gont.com.ar || fgont@si6networks.com
PGP Fingerprint: 7809 84F5 322E 45C7 F1C9 3945 96EE A9EF D076 FFF1
