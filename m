From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: No interfaces under /proc/sys/net/ipv4/conf/
Date: Thu, 22 Jun 2006 12:20:52 +0300
Message-ID: <200606221220.52935.hasso@estpak.ee>
References: <200606211631.39656.hasso@estpak.ee> <200606221154.20999.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:29655 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S1161021AbWFVJVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 05:21:10 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200606221154.20999.hasso@estpak.ee>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hasso Tepper:
> I can think of workarounds for most of problems (although it breaks a
> hell lot of software here), but how I suppose to configure ipv6
> settings for interfaces which have to obtain global ipv6 address via
> autoconf so that it will work even if cable is not plugged in? I did
> via /etc/sysctl.conf, but now ... machine boots with no link => no
> link-local address => no /proc/sys/net/ipv6/conf/<interfce> =>
> configuration fails.

Just realized (via practical experience) that same question applies to 
interfaces configured via dhcp.


regards,

-- 
Hasso Tepper
