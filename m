From: Patrick McHardy <kaber@trash.net>
Subject: Re: iptables broken on ppc (ptrace too?) (2.6.17-rc3)
Date: Sun, 14 May 2006 19:15:56 +0200
Message-ID: <446765CC.8020500@trash.net>
References: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vger.kernel.org@ut.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:29639 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751283AbWENRP6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 13:15:58 -0400
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0605141822260.26018@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
> Iptables seems to be broken on ppc for me. Kernel 2.6.17-rc3 (currently
> compiling rc4+git). 32-bit ppc, ARCH=ppc with PReP target. Iptables
> userland binary is from the latest Debian unstable (1.3.3-2).
> 
> The symptoms: iptables usually just tells Invalid Argument on any
> modification attempt. I'm trying to set up a simple one-rule NAT for test:
> iptables -t nat -A POSTROUTING -s 172.30.0.0/24 -j SNAT --to 10.0.0.1
> and it usually fails but has succeeded 2 times (I now have 2 rules of
> this kind and they seem to just wotk once set up). Trying to delete the
> second rule (either by replacing -A with -D or using just -D 2) gives
> the same error.


This should already be fixed in -rc4.
