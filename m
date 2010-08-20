From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Fri, 20 Aug 2010 08:34:30 +0200
Message-ID: <1282286070.2295.6.camel@edumazet-laptop>
References: <bug-16626-10286@https.bugzilla.kernel.org/>
	 <20100819152143.8a57c465.akpm@linux-foundation.org>
	 <4C6E0C99.2060407@fs.uni-ruse.bg>
	 <20100819221142.b8f6a70a.akpm@linux-foundation.org>
	 <4C6E1CBA.2060605@fs.uni-ruse.bg>
	 <20100819232019.6f6074a8.akpm@linux-foundation.org>
	 <4C6E202E.5030406@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63047 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905Ab0HTGf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Aug 2010 02:35:58 -0400
Received: by wwi17 with SMTP id 17so3606246wwi.1
        for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 23:35:57 -0700 (PDT)
In-Reply-To: <4C6E202E.5030406@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 20 ao=C3=BBt 2010 =C3=A0 09:26 +0300, Plamen Petrov a =C3=A9=
crit :
> Posting this only in the hope that it will be helpfull to the
> "net guys"...

Its a forwarding setup.

Please post

ifconfig -a
iptables -nvL
iptables -t nat -nvL
iptables -t mangle -nvL
ip route
ethtool -k eth0   (& eth1 ...)

Try to disable gro ?
ethtool -K eth0 gro off
ethtool -K eth1 gro off


