From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some
 time
Date: Tue, 2 Sep 2008 12:06:43 +0300 (EEST)
Message-ID: <alpine.LRH.1.10.0809021205450.24795@netcore.fi>
References: <20080831182034.GA12035@pest> <OF9473413E.A12F091F-ON882574B7.00472B7A-882574B7.0047BD14@us.ibm.com> <20080901170101.GA12236@pest> <alpine.LRH.1.10.0809012055460.6006@netcore.fi> <20080901180342.GA13248@pest>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:43844 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbYIBJTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 05:19:30 -0400
In-Reply-To: <20080901180342.GA13248@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Sep 2008, Bernhard Schmidt wrote:
> miredo:~# ping6 -I eth0 ff02::2
> PING ff02::2(ff02::2) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
> 64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.034 ms
> [...]
> miredo:~# ping6 -I eth0 ff02::9
> PING ff02::9(ff02::9) from fe80::216:3eff:feb9:29f5 eth0: 56 data bytes
> ping: sendmsg: Invalid argument
> 64 bytes from fe80::216:3eff:feb9:29f5: icmp_seq=1 ttl=64 time=0.033 ms
>
> I have no idea what the different flags mean or where they come from.

Sorry, as a matter of fact in the quoted text, both sin6_scope_id was 
0.  I was looking at recvmsg where it was different.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
