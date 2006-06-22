From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: No interfaces under /proc/sys/net/ipv4/conf/
Date: Thu, 22 Jun 2006 11:54:20 +0300
Message-ID: <200606221154.20999.hasso@estpak.ee>
References: <200606211631.39656.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:43476 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S932454AbWFVIyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:54:23 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200606211631.39656.hasso@estpak.ee>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> After upgrade to 2.6.16.20 from 2.6.11 I discovered that no dynamic
> interfaces (vlans, tunnels) appear under /proc/sys/net/ipv4/conf/.
> /proc/sys/net/ipv6/conf/ is OK.

OK, realised out that it's feature. Entries in /proc/sys/net/*/conf/ are 
not created if interface doesn't have at least one ipv4/ipv6 address.

I can think of workarounds for most of problems (although it breaks a hell 
lot of software here), but how I suppose to configure ipv6 settings for 
interfaces which have to obtain global ipv6 address via autoconf so that 
it will work even if cable is not plugged in? I did via /etc/sysctl.conf,
but now ... machine boots with no link => no link-local address => 
no /proc/sys/net/ipv6/conf/<interfce> => configuration fails.


regards,

-- 
Hasso Tepper

