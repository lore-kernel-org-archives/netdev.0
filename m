From: Vlado Drzik <vlado@ttx.sk>
Subject: Re: ipset 6.x - bitmap:ip,mac not working
Date: Sun, 15 Jan 2012 18:57:59 +0100
Message-ID: <4F1313A7.4030305@ttx.sk>
References: <4F13044A.7070900@ttx.sk> <alpine.DEB.2.00.1201151827460.29134@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ttx02.ttx-net.sk ([193.110.187.3]:44658 "EHLO ttx02.ttx-net.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751712Ab2AOR6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 12:58:11 -0500
In-Reply-To: <alpine.DEB.2.00.1201151827460.29134@blackhole.kfki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Many Thanks Jozsef,  That was quick.
Indeed it works now.

I haven't noticed that syntax has changed.

Regads,
Vladimir

On 1/15/2012 18:28, Jozsef Kadlecsik wrote:
>
>> iptables -I INPUT -i eth0 -m set --match-set ipmac_test src
> That's a wrong rule: bitmap:ip,mac is a two dimensional set and therefore 
> it requires two directional parameters:
>
> iptables -I INPUT -i eth0 -m set --match-set ipmac_test src,src
>
> Best regards,
> Jozsef
