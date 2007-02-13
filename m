From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 18:07:55 +0000
Message-ID: <9c46321e0702131007g5eaa291cpa8459715260b34c1@mail.gmail.com>
References: <200702131529.04708.hasso@estpak.ee>
	 <20070213090224.2826859f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hasso Tepper" <hasso@estpak.ee>, netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:6260 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbXBMSIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 13:08:00 -0500
Received: by ug-out-1314.google.com with SMTP id 44so301588uga
        for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 10:07:56 -0800 (PST)
In-Reply-To: <20070213090224.2826859f@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 2/13/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > You can disable it in /proc/sys/net/ipv6/conf/default/... and then
> > reenable it on the interfaces that you actually want.

  Is there any technical reason to not have the sysconf entries
available at interface creation? It seems to me that this solution is
very intrusive. Imagine for instance i'm developing some custom
application that uses a TAP interface and i don't want any
autoconfiguration over this interface. For instance a multi-homed host
creating a custom tunnel. Within the current rules i would have to
disable autoconfiguration system-wide to influence the expected
behaviour. Also, this is not reliable as a different application (or a
negligent user) may change back the sysconf values before i set the
TAP interface up.

  Unless there are strong technical reasons against it, it would seem
to me that having conf/tapX/{autoconf, accept_ra} (as an example)
available after the interface is created would provide the cleaner and
most reliable interface.

  Hugo
