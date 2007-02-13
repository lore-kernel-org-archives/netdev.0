From: "Hugo Santos" <hugosantos@gmail.com>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 19:24:32 +0000
Message-ID: <9c46321e0702131124q33b4e263ybc38555cf1544769@mail.gmail.com>
References: <200702131529.04708.hasso@estpak.ee>
	 <20070213185820.GB25362@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Hasso Tepper" <hasso@estpak.ee>, netdev@vger.kernel.org
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:11928 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbXBMTYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 14:24:34 -0500
Received: by ug-out-1314.google.com with SMTP id 44so325605uga
        for <netdev@vger.kernel.org>; Tue, 13 Feb 2007 11:24:32 -0800 (PST)
In-Reply-To: <20070213185820.GB25362@hmsreliant.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil,

On 2/13/07, Neil Horman <nhorman@tuxdriver.com> wrote:
> Can't this simply be fixed by adding a custom udev rule?  Correct me if I'm
> wrong, but the only reason that interfaces come up automatically after their
> appropriate module is inserted is because most distos udev rules issue an ifup
> $DEVICE when they get a creation event for $DEVICE.  Why not add a custom rule
> in for net device creation events to set appropriate sysctl values before the
> ifup is issued.

  The issue is not as much with automatic auto-configuration but with
not being able to disable auto-configuration (and others) before
setting the interface up.

  Hugo
