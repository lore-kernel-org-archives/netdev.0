From: Alexander Hoogerhuis <alexh@boxed.no>
Subject: Re: A patch you wrote some time ago (aka: "[patch 41/54] ICMP: Fix
 icmp_errors_use_inbound_ifaddr sysctl")
Date: Wed, 20 Apr 2011 11:11:59 +0200
Message-ID: <4DAEA35F.3030908@boxed.no>
References: <20110419165411.GO9569@sequoia.sous-sol.org> <4DAE9824.10802@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DAE9824.10802@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also, in a quick followup on myself, this is ambiguous, as it does not 
state that it will select the primary IP. I've

The second part is that RFC 5798 (VRRP v3) lists in section 8.1.1:

>    The IPv4 source address of an ICMP redirect should be the address
>    that the end-host used when making its next-hop routing decision.

I.e. the settings in linux, with or without the sysctl flag set, would 
run against this.

mvh,
A
-- 
Alexander Hoogerhuis | http://no.linkedin.com/in/alexh
Boxed Solutions AS   | +47 908 21 485 - alexh@boxed.no
"Given enough eyeballs, all bugs are shallow." -Eric S. Raymond
