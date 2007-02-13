From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 19:49:50 +0000
Message-ID: <9c46321e0702131149j4b9b642cvfe397d5bd2a30038@mail.gmail.com>
References: <200702131529.04708.hasso@estpak.ee>
	 <20070213185820.GB25362@hmsreliant.homelinux.net>
	 <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com>
	 <20070213194538.GF25362@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hasso Tepper" <hasso@estpak.ee>, netdev@vger.kernel.org
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:53042 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbXBMTtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 14:49:52 -0500
Received: by ug-out-1314.google.com with SMTP id 44so333314uga
        for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 11:49:51 -0800 (PST)
In-Reply-To: <20070213194538.GF25362@hmsreliant.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, I understand that, but until the IFF_UP flag is set on the interface, it
> doesn't really have any effect on the system as a whole.  You should be able to
> undo any default setting that you want before you call ifup on the interface, or
> am I missing something?

  If i understand what you are proposing, in that context you can't
undo before you set IFF_UP because the sysfs entries do not exist yet,
and undoing later is too late as in the case of auto-configuration for
instance the kernel might already have sent a RtSol.

  Hugo
